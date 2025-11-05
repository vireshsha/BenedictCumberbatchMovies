//
//  APIClient.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case serverError(status: Int)
    case decodingError(Error)
    case networkError(Error)
    case emptyData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .serverError(let s): return "Server returned status \(s)"
        case .decodingError(let e): return "Decoding failed: \(e.localizedDescription)"
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .emptyData: return "No data returned"
        }
    }
}

protocol APIClientProtocol {
    func fetchMoviesForPerson(personId: Int) async -> Result<[Movie], APIError>
    func fetchSimilarMovies(movieId: Int) async -> Result<[Movie], APIError>
}

final class APIClient: APIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchMoviesForPerson(personId: Int) async -> Result<[Movie], APIError> {
        guard var components = URLComponents(string: "\(Constants.baseURL)/discover/movie") else {
            return .failure(.invalidURL)
        }
        components.queryItems = [
            URLQueryItem(name: "api_key", value: Constants.tmdbAPIKey),
            URLQueryItem(name: "with_people", value: "\(personId)"),
            URLQueryItem(name: "sort_by", value: "release_date.desc")
        ]
        guard let url = components.url else { return .failure(.invalidURL) }

        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                return .failure(.serverError(status: http.statusCode))
            }
            let decoder = JSONDecoder()
            let resp = try decoder.decode(MovieResponse.self, from: data)
            return .success(resp.results)
        } catch let decoding as DecodingError {
            return .failure(.decodingError(decoding))
        } catch {
            return .failure(.networkError(error))
        }
    }

    func fetchSimilarMovies(movieId: Int) async -> Result<[Movie], APIError> {
        guard var components = URLComponents(string: "\(Constants.baseURL)/movie/\(movieId)/similar") else {
            return .failure(.invalidURL)
        }
        components.queryItems = [URLQueryItem(name: "api_key", value: Constants.tmdbAPIKey)]
        guard let url = components.url else { return .failure(.invalidURL) }

        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                return .failure(.serverError(status: http.statusCode))
            }
            let decoder = JSONDecoder()
            let resp = try decoder.decode(MovieResponse.self, from: data)
            return .success(resp.results)
        } catch let decoding as DecodingError {
            return .failure(.decodingError(decoding))
        } catch {
            return .failure(.networkError(error))
        }
    }
}

