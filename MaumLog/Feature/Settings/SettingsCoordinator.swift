//
//  SettingsCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/17/25.
//

import UIKit

final class SettingsCoordinator: Coordinator {
    
    // MARK: Components
    
    weak var parent: Coordinator?
    var childrens = [Coordinator]()
    let navigationController : UINavigationController
    
    // MARK: Life Cycle
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = SettingsVC()
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func finish() { parent?.childDidFinish(self) }
    
    deinit { print("SettingsCoordinator 소멸") }
}
