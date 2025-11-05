//
//  MovieDetailViewModel.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import Foundation
import Combine

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published var movie: Movie
    private var storedTask: Task<Void, Never>?

    init(movie: Movie) {
        self.movie = movie
    }

    deinit {
        storedTask?.cancel()
    }
}

