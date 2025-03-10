//
//  HomeVC+Alert.swift
//  MaumLog
//
//  Created by 신정욱 on 12/5/24.
//

import UIKit

import RxSwift

extension HomeVC {
    func presentRemoveAlert(item: any EditButtonCellModel) {
        switch item {
        case let item as SymptomData:
            presentAlert(
                title: String(localized: "알림"),
                message: String(localized: "\"\(item.name)\" 증상을 목록에서 삭제할까요?"),
                acceptTitle: String(localized: "삭제"),
                acceptTask: {
                    SymptomDataManager.shared.delete(target: item) // 등록한 증상 삭제
                    self.symptomView.rx.reloadBinder.onNext(()) // 리로드 메시지 전송
                })
        case let item as MedicineData:
            presentAlert(
                title: String(localized: "알림"),
                message: String(localized: "\"\(item.name)\" 을 목록에서 삭제할까요?"),
                acceptTitle: String(localized: "삭제"),
                acceptTask: {
                    MedicineDataManager.shared.delete(target: item) // 등록한 약물 삭제
                    self.medicineView.rx.reloadBinder.onNext(()) // 리로드 이벤트 전송
                })
        default:
            print(#function, "예외 발생")
        }
    }
}
