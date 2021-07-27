//
//  AppDelegate.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let coordinator = Coordinator(window: window!)
        let listViewModel = ListViewModel(coordinator: coordinator)
        let listViewController = Scene.list(listViewModel)
        coordinator.transition(to: listViewController, using: .root, animated: true)
        return true
    }
}

