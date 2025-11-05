//
//  AppDelegate.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // No window or coordinator here; the SceneDelegate owns the window lifecycle.

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Keep any app-wide setup here if needed; window is created in SceneDelegate.
        return true
    }

    // If you support multiple scenes, you can keep default UIScene configuration here.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}
