//
//  AppCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/16/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    weak var parent: Coordinator?
    var childrens = [Coordinator]()
    let navigationController = UINavigationController()
    
    func push() {
        let tabBarCoordinator = TabBarCoordinator(navigationController)
        tabBarCoordinator.parent = self
        childrens.append(tabBarCoordinator)
        tabBarCoordinator.push()
    }
    
    deinit {
        print("AppCoordinator deinit")
    }
}
