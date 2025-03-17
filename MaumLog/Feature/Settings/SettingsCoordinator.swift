//
//  SettingsCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/17/25.
//

import UIKit

final class SettingsCoordinator: Coordinator {
    weak var parent: Coordinator?
    var childrens = [Coordinator]()
    let navigationController : UINavigationController
    
    init(_ navigationController: UINavigationController) {
        print("SettingsCoordinator 생성")
        self.navigationController = navigationController
    }
    
    func push() {
        let vc = SettingsVC()
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didFinish() { parent?.childDidFinish(self) }
    
    deinit { print("SettingsCoordinator 소멸") }
}
