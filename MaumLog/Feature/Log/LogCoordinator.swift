//
//  LogCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/17/25.
//

import UIKit

final class LogCoordinator: Coordinator {
    weak var parent: Coordinator?
    var childrens = [Coordinator]() // 사용 안함
    let navigationController = UINavigationController()
    
    func push() {
        let vc = LogVC()
        vc.tabBarItem = UITabBarItem(
            title: "기록",
            image: UIImage(named: "log")?.resizeImage(newWidth: 20),
            tag: 1
        )
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
