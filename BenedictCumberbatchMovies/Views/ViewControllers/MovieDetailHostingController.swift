//
//  MovieDetailHostingController.swift
//  BenedictCumberbatchMovies
//
//  Modified to accept coordinator and pass it into the SwiftUI view
//

import UIKit
import SwiftUI

final class MovieDetailHostingController: UIHostingController<MovieDetailView> {

    init(viewModel: MovieDetailViewModel, coordinator: AppCoordinator? = nil) {
        let view = MovieDetailView(viewModel: viewModel, coordinator: coordinator)
        super.init(rootView: view)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}
