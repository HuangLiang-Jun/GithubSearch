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
        let repository = SearchUserRepositoryImpl(searchService: APIServices.searchService)
        let useCase = SearchUsersUseCase(repository: repository)
        let vm = SearchVM(searchUserUseCase: useCase)
        window?.rootViewController = SearchVC(viewModel: vm)
        window?.makeKeyAndVisible()
        return true
    }
}
