//
//  LogCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/17/25.
//

import UIKit

final class LogCoordinator: Coordinator {
    
    // MARK: Components
    
    weak var parent: Coordinator?
    var childrens = [Coordinator]()
    let navigationController = UINavigationController()
    
    // MARK: Life Cycle

    func start() {
        let vc = LogVC()
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(
            title: "기록",
            image: UIImage(named: "log")?.resizeImage(newWidth: 20),
            tag: 1
        )
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func finish() { parent?.childDidFinish(self) }
        
    deinit { print("LogCoordinator deinit") }
    
    // MARK: Methods
    
    func presentAddLogVC(
        _ height: CGFloat,
        _ dismissHandler: @escaping () -> Void
    ) {
        let coordinator = AddLogCoordinator(
            navigationController,
            height,
            dismissHandler
        )
        coordinator.parent = self
        childrens.append(coordinator)
        coordinator.start()
    }
    
    func presentAddSymptomVC(
        _ height: CGFloat?,
        _ dismissHandler: (() -> Void)? = nil
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
        _ height: CGFloat?,
        _ dismissHandler: (() -> Void)? = nil
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
