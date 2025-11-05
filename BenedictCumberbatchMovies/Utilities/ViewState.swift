//
//  ViewState.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import Foundation

enum ViewState<Value> {
    case idle            // Initial state, nothing happening yet
    case loading         // Loading in progress
    case loaded(Value)   // Data successfully loaded
    case empty           // Data loaded but empty
    case error(String)   // Error occurred, with a message
}

extension ViewState {
    /// Returns true if the current state is loading
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    /// Returns the associated value if the state is loaded
    var value: Value? {
        if case .loaded(let data) = self { return data }
        return nil
    }

    /// Returns the error message as a string if the state is error
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }

    /// Returns true if the state is empty
    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
}
