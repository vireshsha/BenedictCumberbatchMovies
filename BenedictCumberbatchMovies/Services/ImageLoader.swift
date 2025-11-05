//
//  ImageLoader.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import Foundation
import UIKit

actor ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, NSData>()

    private init() {}

    func loadImageData(from url: URL) async -> Data? {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached as Data
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let nsData = data as NSData
            cache.setObject(nsData, forKey: url as NSURL)
            return data
        } catch {
            return nil
        }
    }

    // New convenience API expected by MovieCell and tests
    func loadImage(from url: URL) async -> UIImage {
        if let data = await loadImageData(from: url),
           let image = UIImage(data: data) {
            return image
        }
        // Fallback placeholder image
        return UIImage(systemName: "photo") ?? UIImage()
    }
}

