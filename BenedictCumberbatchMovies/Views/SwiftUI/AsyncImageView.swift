//
//  AsyncImageView.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import SwiftUI
import UIKit

/// A simple async image loader view that safely loads remote images and
/// displays a placeholder until loading completes.
@MainActor
struct AsyncImageView: View {
    enum ContentMode {
        case fit, fill
    }

    let url: URL?
    var contentMode: ContentMode = .fit

    @State private var image: Image?

    var body: some View {
        if let image = image {
            // Display the loaded image
            switch contentMode {
            case .fit:
                image
                    .resizable()
                    .scaledToFit()
            case .fill:
                image
                    .resizable()
                    .scaledToFill()
            }
        } else {
            // Placeholder while loading
            Rectangle()
                .foregroundColor(.gray.opacity(0.2))
                .overlay(ProgressView())
                .task {
                    await loadImage()
                }
        }
    }

    /// Handles image loading and safe UI updates.
    private func loadImage() async {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            image = Image(systemName: "photo")
            return
        }
        #endif

        guard let url = url else {
            image = Image(systemName: "photo")
            return
        }

        if let data = await ImageLoader.shared.loadImageData(from: url),
           let uiImage = UIImage(data: data) {
            image = Image(uiImage: uiImage)
        } else {
            image = Image(systemName: "photo")
        }
    }

}
