//
//  HomeCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/16/25.
//

import UIKit

final class HomeCoordinator: Coordinator {
    weak var parent: Coordinator?
    var childrens = [Coordinator]()
    let navigationController = UINavigationController()
    
    func push() {
        let vc = HomeVC()
        vc.tabBarItem = UITabBarItem(
            title: "대시보드",
            image: UIImage(named: "dashboard")?.resizeImage(newWidth: 22),
            tag: 0
        )
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushSettingsVC() {
        let settingsCoordinator = SettingsCoordinator(navigationController)
        settingsCoordinator.parent = self
        childrens.append(settingsCoordinator)
        settingsCoordinator.push()
    }
    
    deinit {
        print("HomeCoordinator deinit")
    }
}
