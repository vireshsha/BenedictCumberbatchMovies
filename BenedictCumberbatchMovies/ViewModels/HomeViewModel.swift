//
//  HomeViewModel.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import Foundation
import Combine // <-- add this
import UIKit

@MainActor
final class HomeViewModel: ObservableObject {  // <- conform to ObservableObject
    private let apiClient: APIClientProtocol
    
    @Published var state: ViewState<[Movie]> = .idle

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadMovies() async {
        state = .loading
        let result = await apiClient.fetchMoviesForPerson(personId: Constants.cumberbatchPersonId)
        switch result {
        case .success(let movies):
            state = movies.isEmpty ? .empty : .loaded(movies)
        case .failure(let error):
            state = .error(error.localizedDescription)
        }
    }
}

