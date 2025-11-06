//
//  Movie.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import Foundation

struct MovieResponse: Decodable {
    // Make paging fields optional to avoid decoding failures when TMDB omits them
    let page: Int?
    let results: [Movie]
    let totalPages: Int?
    let totalResults: Int?
}

struct Movie: Identifiable, Equatable, Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?

    // Build a robust image URL that avoids double slashes and logs when missing
    var posterURL: URL? {
        guard let path = posterPath, !path.isEmpty else {
            #if DEBUG
            print("Movie \(id) '\(title)' has no posterPath")
            #endif
            return nil
        }
        let base = Constants.imageBaseURL.hasSuffix("/") ? String(Constants.imageBaseURL.dropLast()) : Constants.imageBaseURL
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let urlString = "\(base)/\(normalizedPath)"
        return URL(string: urlString)
    }

    var backdropURL: URL? {
        guard let path = backdropPath, !path.isEmpty else {
            #if DEBUG
            print("Movie \(id) '\(title)' has no backdropPath")
            #endif
            return nil
        }
        let base = Constants.imageBaseURL.hasSuffix("/") ? String(Constants.imageBaseURL.dropLast()) : Constants.imageBaseURL
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let urlString = "\(base)/\(normalizedPath)"
        return URL(string: urlString)
    }
}
