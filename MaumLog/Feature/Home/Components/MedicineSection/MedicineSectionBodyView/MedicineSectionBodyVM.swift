//
//  MedicineSectionBodyVM.swift
//  MaumLog
//
//  Created by 신정욱 on 3/11/25.
//

import Foundation

import RxSwift
import RxCocoa

final class MedicineSectionBodyVM {
    
    struct Input {
        let isEditing: Observable<Bool>
        let reloadEvent: Observable<Void>
        let itemToRemove: Observable<EditButtonCellModel>
    }
    
    struct Output {
        let medicineSectionDataArr: Observable<[MedicineSectionData]>
        let reloadEvent: Observable<Void>
        let isDataEmpty: Observable<Bool>
        let itemToRemove: Observable<EditButtonCellModel>
    }
    
    private let bag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let medicineDataArr = BehaviorSubject<[MedicineData]>(
            value: MedicineDataManager.shared.read()
        )
        
        // 약물 데이터 섹션 데이터로 바인딩
        let medicineSectionDataArr = Observable
            .combineLatest(medicineDataArr, input.isEditing)
            .map { dataArr, isEditing in
                dataArr.map { $0.updated(isEditMode: isEditing) }
                    .sectionDataArr // 섹션 데이터로 변경
            }
        
        // 데이터 리로드 요청 시, 데이터 재요청
        input.reloadEvent
            .map { _ in MedicineDataManager.shared.read() }
            .bind(to: medicineDataArr)
            .disposed(by: bag)
        
        // 셀 데이터가 비어있으면, 대체 화면 표시
        let isDataEmpty = medicineSectionDataArr
            .map { $0.cellDataArr.isEmpty }
        
        // 편집 상태일 때, 삭제할 아이템 전달
        let itemToRemove = input.itemToRemove
            .withLatestFrom(input.isEditing) { $1 ? $0 : nil }
            .compactMap { $0 }
        
        return Output(
            medicineSectionDataArr: medicineSectionDataArr,
            reloadEvent: input.reloadEvent,
            isDataEmpty: isDataEmpty,
            itemToRemove: itemToRemove
        )
    }
}
