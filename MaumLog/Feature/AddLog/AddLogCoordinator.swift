//
//  AddLogCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/18/25.
//

import UIKit

final class AddLogCoordinator: Coordinator {
    
    // MARK: Components
    
    weak var parent: Coordinator?
    var childrens = [Coordinator]()
    let navigationController: UINavigationController
    
    private let height: CGFloat
    private let dismissHandler: () -> Void

    // MARK: Life Cycle
    
    init(
        _ navigationController: UINavigationController,
        _ height: CGFloat,
        _ dismissHandler: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.height = height
        self.dismissHandler = dismissHandler
    }
    
    func start() {
        let fraction = UISheetPresentationController.Detent.custom { [weak self] _ in
            self?.height
        }
        
        let vc = AddLogVC()
        vc.coordinator = self
        vc.dismissTask = dismissHandler
        vc.sheetPresentationController?.detents = [fraction, .large()]
        vc.sheetPresentationController?.preferredCornerRadius = 15
        vc.sheetPresentationController?.prefersGrabberVisible = true
        
        navigationController.present(vc, animated: true)
    }
    
    func finish() { parent?.childDidFinish(self) }
    
    // MARK: Methods
    
    deinit { print("AddLogCoordinator deinit") }
}
