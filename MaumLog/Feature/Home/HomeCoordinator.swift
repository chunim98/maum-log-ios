//
//  HomeCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/16/25.
//

import UIKit

final class HomeCoordinator: Coordinator {
    
    // MARK: Components
    
    weak var parent: Coordinator?
    var childrens = [Coordinator]()
    let navigationController = UINavigationController()
        
    // MARK: Life Cycle
    
    func start() {
        let vc = HomeVC()
        vc.tabBarItem = UITabBarItem(
            title: "대시보드",
            image: UIImage(named: "dashboard")?.resizeImage(newWidth: 22),
            tag: 0
        )
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    deinit { print("HomeCoordinator deinit") }
    
    // MARK: Methods
    
    func pushSettingsVC() {
        let coordinator = SettingsCoordinator(navigationController)
        coordinator.parent = self
        childrens.append(coordinator)
        coordinator.start()
    }
    
    func presentAddSymptomVC(
        _ height: CGFloat,
        _ dismissHandler: @escaping () -> Void
    ) {
        let coordinator = AddSymptomCoordinator(
            navigationController,
            height,
            dismissHandler
        )
        coordinator.parent = self
        childrens.append(coordinator)
        coordinator.start()
    }
    
    func presentAddMedicineVC(
        _ height: CGFloat,
        _ dismissHandler: @escaping () -> Void
    ) {
        let coordinator = AddMedicineCoordinator(
            navigationController,
            height,
            dismissHandler
        )
        coordinator.parent = self
        childrens.append(coordinator)
        coordinator.start()
    }
}
