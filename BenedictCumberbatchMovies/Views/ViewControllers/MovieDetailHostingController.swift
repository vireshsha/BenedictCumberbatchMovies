//
//  MovieDetailHostingController.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import UIKit
import SwiftUI

final class MovieDetailHostingController: UIHostingController<MovieDetailView> {
    
    init(viewModel: MovieDetailViewModel) {
        // MovieDetailView requires ObservableObject
        let view = MovieDetailView(viewModel: viewModel)
        super.init(rootView: view)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}
