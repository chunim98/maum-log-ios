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
        let tappedGoSettingsButton: Observable<Void>
        let startRefreshing: Observable<Void>
        let goAddSymptom: Observable<Void>
        let presentRemoveAlert: Observable<EditButtonCellModel>
        let goAddMedicine: Observable<Void>
        let presentRemoveMedicineAlert: Observable<EditButtonCellModel>
    }
    
    struct Output {
        let goSettings: Observable<Void>
        let endRefreshing: Observable<Void>
        let goAddSymptom: Observable<Void>
        let presentRemoveAlert: Observable<EditButtonCellModel>
        let goAddMedicine: Observable<Void>
        let presentRemoveMedicineAlert: Observable<EditButtonCellModel>

    }
    
    let calendarSubVM = CalendarSubVM()
    
    private let bag = DisposeBag()

    func transform(_ input: Input) -> Output {
        // 설정 화면으로 이동
        let goSettings = input.tappedGoSettingsButton
        
        // 스크롤 뷰 리프레쉬
        let endRefreshing = input.startRefreshing
            .delay(.milliseconds(750), scheduler: MainScheduler.instance) // 리프레시 기분을 내는 0.75초 지연
            // 리프레쉬 로직 추가해야함
        
        // 증상 추가 모달 띄우기
        let goAddSymptom = input.goAddSymptom
        
        // 증상 삭제 얼럿 띄우기
        let presentRemoveAlert = input.presentRemoveAlert
        
        // 약물 추가 모달 띄우기
        let goAddMedicine = input.goAddMedicine
        
        // 약물 삭제 얼럿 띄우기
        let presentRemoveMedicineAlert = input.presentRemoveMedicineAlert
        
        return Output(
            goSettings: goSettings,
            endRefreshing: endRefreshing,
            goAddSymptom: goAddSymptom,
            presentRemoveAlert: presentRemoveAlert,
            goAddMedicine: goAddMedicine,
            presentRemoveMedicineAlert: presentRemoveMedicineAlert)
    }
}
