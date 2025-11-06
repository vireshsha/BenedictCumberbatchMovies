//
//  ImageLoader.swift
//  BenedictCumberbatchMovies
//
//  Thread-safe async image loader with in-memory data cache.
//

import Foundation
import UIKit

actor ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, NSData>()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
        // Reasonable default cost limit; tune as needed
        cache.totalCostLimit = 20 * 1024 * 1024 // 20 MB
    }

    /// Loads raw image data for a URL with simple in-memory caching.
    /// - Parameter url: The image URL.
    /// - Returns: Data if successfully loaded, otherwise nil.
    func loadImageData(from url: URL) async -> Data? {
        let key = url as NSURL

        // Serve from cache if present
        if let cached = cache.object(forKey: key) {
            return cached as Data
        }

        // Special-case data: URLs to support unit tests without networking
        if url.scheme?.lowercased() == "data" {
            if let data = decodeDataURL(url) {
                cache.setObject(data as NSData, forKey: key, cost: data.count)
                return data
            } else {
                #if DEBUG
                print("ImageLoader failed to decode data URL: \(url.absoluteString)")
                #endif
                return nil
            }
        }

        // Fetch via URLSession
        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                #if DEBUG
                print("ImageLoader HTTP \(http.statusCode) for \(url.absoluteString)")
                #endif
                return nil
            }
            let nsData = data as NSData
            cache.setObject(nsData, forKey: key, cost: data.count)
            return data
        } catch {
            #if DEBUG
            print("ImageLoader error for \(url.absoluteString): \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    /// Loads a UIImage for a URL, using the data loader and cache.
    /// - Parameter url: The image URL.
    /// - Returns: UIImage if successful, otherwise a placeholder system image.
    func loadImage(from url: URL) async -> UIImage {
        // Try cached data or fetch
        if let data = await loadImageData(from: url),
           let image = UIImage(data: data) {
            return image
        }

        // Fallback placeholder to avoid nil image crashes in UI
        return UIImage(systemName: "photo") ?? UIImage()
    }

    // MARK: - Helpers

    /// Decodes a data URL (data:[<mediatype>][;base64],<data>)
    private func decodeDataURL(_ url: URL) -> Data? {
        // We only support base64-encoded data URLs for simplicity
        guard url.scheme?.lowercased() == "data" else { return nil }
        // URLComponents won’t parse data URLs well; work on the absoluteString
        let s = url.absoluteString
        guard let commaIdx = s.firstIndex(of: ",") else { return nil }
        let meta = s[..<commaIdx].lowercased()
        let payload = String(s[s.index(after: commaIdx)...])

        if meta.contains(";base64") {
            return Data(base64Encoded: payload)
        } else {
            // Percent-decoded raw data
            return payload.removingPercentEncoding?.data(using: .utf8)
        }
    }
}
