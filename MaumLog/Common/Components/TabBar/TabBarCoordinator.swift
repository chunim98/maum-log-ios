//
//  TabBarCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/17/25.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    weak var parent: Coordinator?
    var childrens = [Coordinator]() // 사용안함
    let navigationController : UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func push() {
        let tabbarController = TabBarVC()
        let homeCoordinator = HomeCoordinator()
        let logCoordinator = LogCoordinator()
        
        homeCoordinator.parent = parent
        logCoordinator.parent = parent
        
        // TabBarCoordinator는 중계 역할만 하기 때문에 부모의 자식으로 등록
        parent?.childrens.append(homeCoordinator)
        parent?.childrens.append(logCoordinator)
        
        tabbarController.viewControllers = [
            homeCoordinator.navigationController,
            logCoordinator.navigationController,
        ]
        
        homeCoordinator.push()
        logCoordinator.push()

        navigationController.isNavigationBarHidden = true
        navigationController.pushViewController(tabbarController, animated: true)
    }
    
    deinit {
        print("TabBarCoordinator deinit")
    }
}
