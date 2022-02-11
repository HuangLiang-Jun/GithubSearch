//
//  AppDelegate.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = SearchVC()
        window?.makeKeyAndVisible()
        return true
    }
}
