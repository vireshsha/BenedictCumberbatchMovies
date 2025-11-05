//
//  BenedictCumberbatchMoviesApp.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import SwiftUI
import UIKit

struct BenedictCumberbatchMoviesApp: App {

    private let coordinatorHolder = AppCoordinatorHolder()

    var body: some Scene {
        WindowGroup {
            CoordinatorRootView(coordinatorHolder: coordinatorHolder)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// MARK: - Coordinator Holder (non-observed)
final class AppCoordinatorHolder {
    let coordinator: AppCoordinator

    init() {
        let navigationController = UINavigationController()
        self.coordinator = AppCoordinator(navigationController: navigationController)
        self.coordinator.start()
    }
}

// MARK: - UIKit Root Wrapper
struct CoordinatorRootView: UIViewControllerRepresentable {
    let coordinatorHolder: AppCoordinatorHolder

    func makeUIViewController(context: Context) -> UINavigationController {
        return coordinatorHolder.coordinator.navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

