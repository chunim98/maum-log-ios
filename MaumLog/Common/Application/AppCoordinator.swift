//
//  AppCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/16/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    weak var parent: Coordinator? // 사용 안함
    var childrens = [Coordinator]()
    let navigationController = UINavigationController()
    
    func start() {
        let tabBarCoordinator = TabBarCoordinator(navigationController)
        tabBarCoordinator.parent = self
        childrens.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }
    
    deinit {
        print("AppCoordinator deinit")
    }
}
