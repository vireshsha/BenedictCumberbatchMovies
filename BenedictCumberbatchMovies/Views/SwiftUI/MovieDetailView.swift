//
//  MovieDetailView.swift
//  BenedictCumberbatchMovies
//
//  Updated to display similar movies and accept coordinator, with accessibility identifiers
//

import SwiftUI

struct MovieDetailView: View {
    @ObservedObject var viewModel: MovieDetailViewModel
    weak var coordinator: AppCoordinator?

    init(viewModel: MovieDetailViewModel, coordinator: AppCoordinator? = nil) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let posterURL = viewModel.movie.posterURL {
                    AsyncImageView(url: posterURL, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 380)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .accessibilityHidden(true)
                }

                Text(viewModel.movie.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .accessibilityIdentifier("detailTitle")

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
                    .accessibilityIdentifier("detailOverview")

                // Similar movies section
                if viewModel.isLoadingSimilar {
                    ProgressView("Loading similar movies...")
                        .padding(.top, 8)
                        .accessibilityIdentifier("similarLoading")
                } else if !viewModel.similarMovies.isEmpty {
                    Text("Similar Movies")
                        .font(.headline)
                        .padding(.top)
                        .accessibilityIdentifier("similarSectionTitle")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.similarMovies, id: \.id) { movie in
                                VStack {
                                    if let posterURL = movie.posterURL {
                                        AsyncImageView(url: posterURL, contentMode: .fill)
                                            .frame(width: 120, height: 180)
                                            .cornerRadius(8)
                                            .shadow(radius: 2)
                                    } else {
                                        Rectangle()
                                            .frame(width: 120, height: 180)
                                            .cornerRadius(8)
                                            .foregroundColor(Color.gray.opacity(0.2))
                                    }
                                    Text(movie.title)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .frame(width: 120)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    coordinator?.showDetail(movie: movie)
                                }
                                .accessibilityIdentifier("similarItem_\(movie.id)")
                            }
                        }
                        .padding(.vertical, 4)
                        .accessibilityIdentifier("similarList")
                    }
                } else {
                    // No similar movies - optional message
                    if !viewModel.isLoadingSimilar {
                        Text("No similar movies found.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            .accessibilityIdentifier("similarEmpty")
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .padding(.top, 16)
        }
        .navigationTitle(viewModel.movie.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

