//
//  MovieDetailViewModel.swift
//  BenedictCumberbatchMovies
//
//  Updated to load similar movies with injectable service for testability
//

import Foundation
import Combine

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published var movie: Movie
    @Published var similarMovies: [Movie] = []
    @Published var isLoadingSimilar: Bool = false

    private var storedTask: Task<Void, Never>?
    private let similarService: SimilarServiceProtocol

    init(movie: Movie, similarService: SimilarServiceProtocol? = nil) {
        self.movie = movie
        // Resolve the default inside the @MainActor initializer to avoid referencing an actor-isolated static in a nonisolated default argument.
        if let similarService {
            self.similarService = similarService
        } else {
            self.similarService = SimilarService.shared
        }
        loadSimilarMovies()
    }

    func loadSimilarMovies() {
        storedTask?.cancel()
        storedTask = Task { [weak self] in
            guard let self else { return }
            self.isLoadingSimilar = true
            do {
                let results = try await similarService.fetchSimilarMovies(for: self.movie.id)
                // filter out same movie if present
                self.similarMovies = results.filter { $0.id != self.movie.id }
            } catch {
                // handle gracefully - set to empty
                self.similarMovies = []
            }
            self.isLoadingSimilar = false
        }
    }

    deinit {
        storedTask?.cancel()
    }
}
