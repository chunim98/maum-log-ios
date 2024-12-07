//
//  LogVC+Alert.swift
//  MaumLog
//
//  Created by 신정욱 on 12/7/24.
//

import UIKit
import RxSwift

extension LogVC {
    func presentShouldAddSymptomAlert() {
        presentAlert(
            title: String(localized: "알림"),
            message: String(localized: "부작용, 기타 증상을 기록하려면\n먼저 증상을 등록해야 해요."),
            acceptTitle: String(localized: "등록"),
            acceptTask: { [weak self] in
                guard let self else { return }
                
                // 모달 높이 조정
                let fraction = UISheetPresentationController.Detent.custom { _ in self.view.frame.height * 0.6 }

                let vc = AddSymptomVC()
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [fraction]
                    sheet.preferredCornerRadius = .chuRadius
                }
                
                present(vc, animated: true)
            })
    }
    
    func presentShouldAddMedicineAlert() {
        presentAlert(
            title: String(localized: "알림"),
            message: String(localized: "복약한 시간을 기록하려면\n먼저 복용 중인 약을 등록해야 해요."),
            acceptTitle: String(localized: "등록"),
            acceptTask: { [weak self] in
                guard let self else { return }

                // 모달 높이 조정
                let fraction = UISheetPresentationController.Detent.custom { _ in self.view.frame.height * 0.3 }

                let vc = AddMedicineVC()
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [fraction]
                    sheet.preferredCornerRadius = .chuRadius
                }
                
                present(vc, animated: true)
            })
    }
    
    func presentRemoveAlert(item: any EditButtonCellModel) {
        guard let item = item as? LogData else { return }
        
        presentAlert(
            title: String(localized: "알림"),
            message: String(localized: "기록을 삭제할까요?"),
            acceptTitle: String(localized: "삭제"),
            acceptTask: { [weak self] in
                LogDataManager.shared.delete(target: item)
                self?.reloadSectionData.onNext(())
            })
    }
}
