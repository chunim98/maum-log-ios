//
//  AddMedicineCoordinator.swift
//  MaumLog
//
//  Created by 신정욱 on 3/18/25.
//

import UIKit

final class AddMedicineCoordinator: Coordinator {
    
    // MARK: Components
    
    weak var parent: Coordinator?
    var childrens = [Coordinator]()
    let navigationController: UINavigationController
    
    private let height: CGFloat?
    private let dismissHandler: (() -> Void)?
    
    // MARK: Life Cycle
    
    init(
        _ navigationController: UINavigationController,
        _ height: CGFloat?,
        _ dismissHandler: (() -> Void)? = nil
    ) {
        self.navigationController = navigationController
        self.height = height
        self.dismissHandler = dismissHandler
    }
    
    func start() {
        let fraction = UISheetPresentationController.Detent.custom { [weak self] _ in
            self?.height
        }
        
        let vc = AddMedicineVC()
        vc.coordinator = self
        vc.dismissTask = dismissHandler
        vc.sheetPresentationController?.detents = [fraction]
        vc.sheetPresentationController?.preferredCornerRadius = 15 // 모달 모서리 굴곡
        navigationController.present(vc, animated: true)
    }
    
    func finish() { parent?.childDidFinish(self) }
        
    deinit { print("AddMedicineCoordinator deinit") }
}
