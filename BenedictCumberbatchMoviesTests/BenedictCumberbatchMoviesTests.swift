//
//  BenedictCumberbatchMoviesTests.swift
//  BenedictCumberbatchMoviesTests
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import XCTest
import SwiftUI
@testable import BenedictCumberbatchMovies

final class BenedictCumberbatchMoviesTests: XCTestCase {

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: config)
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.reset()
    }

    func testSuccessReturnsMovies() async throws {
        // Arrange
        let session = makeSession()
        let client = await APIClient(session: session)

        // Build the exact URL that APIClient will request
        var components = URLComponents(string: "\(await Constants.baseURL)/discover/movie")!
        components.queryItems = await [
            URLQueryItem(name: "api_key", value: Constants.tmdbAPIKey),
            URLQueryItem(name: "with_people", value: "\(Constants.cumberbatchPersonId)"),
            URLQueryItem(name: "sort_by", value: "release_date.desc")
        ]
        let expectedURL = components.url!

        // Prepare JSON payload matching MovieResponse
        let json = """
        {
          "page": 1,
          "results": [
            {
              "id": 101,
              "title": "Movie A",
              "overview": "Overview A",
              "poster_path": "/a.png",
              "backdrop_path": "/ab.png",
              "release_date": "2024-01-01"
            },
            {
              "id": 102,
              "title": "Movie B",
              "overview": "Overview B",
              "poster_path": "/b.png",
              "backdrop_path": "/bb.png",
              "release_date": "2023-05-05"
            }
          ],
          "total_pages": 1,
          "total_results": 2
        }
        """.data(using: .utf8)!

        URLProtocolStub.setStub(for: expectedURL, data: json, statusCode: 200)

        // Act
        let result = await client.fetchMoviesForPerson(personId: Constants.cumberbatchPersonId)

        // Assert
        switch result {
        case .success(let movies):
            // Hop to main actor to read any potentially main-actor-isolated values,
            // then assert on plain values to avoid autoclosure isolation issues.
            let firstId: Int = await MainActor.run { movies[0].id }
            let firstTitle: String = await MainActor.run { movies[0].title }
            let secondId: Int = await MainActor.run { movies[1].id }
            let count: Int = movies.count

            XCTAssertEqual(count, 2)
            XCTAssertEqual(firstId, 101)
            XCTAssertEqual(firstTitle, "Movie A")
            XCTAssertEqual(secondId, 102)
        case .failure(let error):
            XCTFail("Expected success but got error: \(error)")
        }
    }

    func testServerErrorReturnsFailure() async throws {
        // Arrange
        let session = makeSession()
        let client = await APIClient(session: session)

        var components = URLComponents(string: "\(await Constants.baseURL)/discover/movie")!
        components.queryItems = await [
            URLQueryItem(name: "api_key", value: Constants.tmdbAPIKey),
            URLQueryItem(name: "with_people", value: "99999"),
            URLQueryItem(name: "sort_by", value: "release_date.desc")
        ]
        let expectedURL = components.url!

        URLProtocolStub.setStub(for: expectedURL, data: Data("{}".utf8), statusCode: 500)

        // Act
        let result = await client.fetchMoviesForPerson(personId: 99999)

        // Assert
        switch result {
        case .success:
            XCTFail("Expected failure for server error")
        case .failure(let error):
            if case .serverError(let status) = error {
                XCTAssertEqual(status, 500)
            } else {
                XCTFail("Expected .serverError, got \(error)")
            }
        }
    }

    func testDecodingErrorReturnsFailure() async throws {
        // Arrange
        let session = makeSession()
        let client = await APIClient(session: session)

        var components = URLComponents(string: "\(await Constants.baseURL)/discover/movie")!
        components.queryItems = await [
            URLQueryItem(name: "api_key", value: Constants.tmdbAPIKey),
            URLQueryItem(name: "with_people", value: "12345"),
            URLQueryItem(name: "sort_by", value: "release_date.desc")
        ]
        let expectedURL = components.url!

        // Malformed JSON (results should be an array)
        let badJSON = """
        {
          "page": 1,
          "results": { "not": "an array" },
          "total_pages": 1,
          "total_results": 1
        }
        """.data(using: .utf8)!

        URLProtocolStub.setStub(for: expectedURL, data: badJSON, statusCode: 200)

        // Act
        let result = await client.fetchMoviesForPerson(personId: 12345)

        // Assert
        switch result {
        case .success:
            XCTFail("Expected decoding failure")
        case .failure(let error):
            if case .decodingError = error {
                // ok
            } else {
                XCTFail("Expected .decodingError, got \(error)")
            }
        }
    }

    func testNetworkErrorReturnsFailure() async throws {
        // Arrange
        let session = makeSession()
        let client = await APIClient(session: session)

        var components = URLComponents(string: "\(await Constants.baseURL)/discover/movie")!
        components.queryItems = await [
            URLQueryItem(name: "api_key", value: Constants.tmdbAPIKey),
            URLQueryItem(name: "with_people", value: "54321"),
            URLQueryItem(name: "sort_by", value: "release_date.desc")
        ]
        let expectedURL = components.url!

        let transportError = URLError(.notConnectedToInternet)
        URLProtocolStub.setError(for: expectedURL, error: transportError)

        // Act
        let result = await client.fetchMoviesForPerson(personId: 54321)

        // Assert
        switch result {
        case .success:
            XCTFail("Expected network failure")
        case .failure(let error):
            if case .networkError(let underlying) = error {
                XCTAssertEqual((underlying as? URLError)?.code, .notConnectedToInternet)
            } else {
                XCTFail("Expected .networkError, got \(error)")
            }
        }
    }
}

// URLProtocol stub to control responses
final class URLProtocolStub: URLProtocol {

    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    // Keyed by URL absoluteString so tests can set per-request stubs
    static var stubs: [String: Stub] = [:]
    static var defaultStub: Stub?

    override class func canInit(with request: URLRequest) -> Bool {
        // Intercept all requests
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let client = client else { return }
        let urlString = request.url?.absoluteString ?? ""

        let stub = URLProtocolStub.stubs[urlString] ?? URLProtocolStub.defaultStub

        if let error = stub?.error {
            client.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = stub?.response {
                client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = stub?.data {
                client.urlProtocol(self, didLoad: data)
            }
            client.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {
        // No-op
    }

    // Helpers
    static func setStub(for url: URL, data: Data?, statusCode: Int = 200, headers: [String: String]? = nil) {
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headers)
        stubs[url.absoluteString] = Stub(data: data, response: response, error: nil)
    }

    static func setError(for url: URL, error: Error) {
        stubs[url.absoluteString] = Stub(data: nil, response: nil, error: error)
    }

    static func reset() {
        stubs.removeAll()
        defaultStub = nil
    }
}

final class AsyncImageViewTests: XCTestCase {

    func testAsyncImageViewInitDefaultsToFit() {
        // Ensure the view can be constructed with defaults
        let view = AsyncImageView(url: nil)
        XCTAssertNotNil(view)
    }

    func testAsyncImageViewWithFitRendersBody() {
        let view = AsyncImageView(url: nil, contentMode: .fit)
        // Access body to ensure the view builds without crashing
        _ = view.body
        XCTAssertTrue(true)
    }

    func testAsyncImageViewWithFillRendersBody() {
        let view = AsyncImageView(url: nil, contentMode: .fill)
        _ = view.body
        XCTAssertTrue(true)
    }
}
