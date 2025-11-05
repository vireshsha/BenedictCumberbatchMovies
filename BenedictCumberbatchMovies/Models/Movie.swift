//
//  Movie.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import Foundation

struct MovieResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Decodable, Identifiable, Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: Constants.imageBaseURL + path)
    }
}
