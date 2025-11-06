//
//  SceneDelegate.swift
//  BenedictCumberbatchMovies
//
//  Fixed for programmatic launch with dependency injection
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var coordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let navigationController = UINavigationController()
        let apiClient = APIClient()
        let coordinator = AppCoordinator(navigationController: navigationController, apiClient: apiClient)
        coordinator.start()
        self.coordinator = coordinator

        // UITest hook: if the UI test passes this argument, push a mock detail screen immediately.
        if ProcessInfo.processInfo.arguments.contains("UITest_ShowMockDetail") {
            let mock = Movie(
                id: 1,
                title: "Mock Movie",
                overview: "A mock overview for UI testing.",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2025-01-01"
            )
            let detailVM = MovieDetailViewModel(movie: mock)
            let hosting = MovieDetailHostingController(viewModel: detailVM)
            navigationController.pushViewController(hosting, animated: false)
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
