//
//  HomeVM.swift
//  MaumLog
//
//  Created by 신정욱 on 7/28/24.
//

import UIKit

import RxSwift

final class HomeVM {
    
    struct Input {
        let refreshEvnet: Observable<Void>
        let pushSettingsEvent: Observable<Void>
        let pushAddSymptomEvent: Observable<Void>
        let pushAddMedicineEvent: Observable<Void>
        let symptomToRemove: Observable<EditButtonCellModel>
        let medicineToRemove: Observable<EditButtonCellModel>
    }
    
    struct Output {
        let refreshEvnet: Observable<Void>
        let pushSettingsEvent: Observable<Void>
        let pushAddSymptomEvent: Observable<Void>
        let pushAddMedicineEvent: Observable<Void>
        let itemToRemove: Observable<EditButtonCellModel>
    }
    
    private let bag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        
        // 스크롤 뷰의 리프레쉬 지연 효과
        let refreshEvnet = input.refreshEvnet
            .delay(.milliseconds(750), scheduler: MainScheduler.instance)
        
        // 삭제할 아이템 스트림을 통합하고, 얼럿 띄우기
        let itemToRemove = Observable
            .merge(input.symptomToRemove, input.medicineToRemove)
        
        return Output(
            refreshEvnet: refreshEvnet,
            pushSettingsEvent: input.pushSettingsEvent,
            pushAddSymptomEvent: input.pushAddSymptomEvent,
            pushAddMedicineEvent: input.pushAddMedicineEvent,
            itemToRemove: itemToRemove
        )
    }
}
