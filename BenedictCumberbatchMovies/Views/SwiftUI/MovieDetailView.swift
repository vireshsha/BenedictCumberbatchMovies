//
//  MovieDetailView.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import SwiftUI

struct MovieDetailView: View {
    @ObservedObject var viewModel: MovieDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let posterURL = viewModel.movie.posterURL {
                    // Preserve aspect ratio, allow it to grow up to a cap without stretching
                    AsyncImageView(url: posterURL, contentMode: .fit)
                        .frame(maxWidth: .infinity)     // expand horizontally
                        .frame(maxHeight: 380)          // cap height; adjust as desired
                        .clipped()                      // clip overflow if any
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .accessibilityHidden(true)      // decorative; title conveys content
                }

                Text(viewModel.movie.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)

                if let release = viewModel.movie.releaseDate {
                    Text("Release: \(release)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Release date \(release)")
                }

                Text(viewModel.movie.overview)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .padding(.top, 16) // keep content below the navigation bar
        }
        .navigationTitle(viewModel.movie.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
