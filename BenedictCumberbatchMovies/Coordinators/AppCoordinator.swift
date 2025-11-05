//
//  AppCoordinator.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get }
    func start()
}

final class AppCoordinator: Coordinator {

    let navigationController: UINavigationController
    private let apiClient: APIClientProtocol

    init(navigationController: UINavigationController = UINavigationController(),
         apiClient: APIClientProtocol = APIClient()) {
        self.navigationController = navigationController
        self.apiClient = apiClient
    }

    func start() {
        let homeVM = HomeViewModel(apiClient: apiClient)
        let homeVC = HomeViewController(viewModel: homeVM, coordinator: self)
        navigationController.viewControllers = [homeVC]
    }

    func showDetail(movie: Movie) {
        let detailVM = MovieDetailViewModel(movie: movie)
        let hosting = MovieDetailHostingController(viewModel: detailVM)
        navigationController.pushViewController(hosting, animated: true)
    }
}
