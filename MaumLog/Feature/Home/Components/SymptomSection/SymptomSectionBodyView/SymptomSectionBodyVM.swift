//
//  SymptomSectionBodyVM.swift
//  MaumLog
//
//  Created by 신정욱 on 3/10/25.
//

import Foundation

import RxSwift
import RxCocoa

final class SymptomSectionBodyVM {
    
    struct Input {
        let isEditing: Observable<Bool>
        let reloadEvent: Observable<Void>
        let selectedModel: Observable<EditButtonCellModel>
    }
    
    struct Output {
        let negativeSectionDataArr: Observable<[SymptomSectionData]>
        let otherSectionDataArr: Observable<[SymptomSectionData]>
        let reloadEvent: Observable<Void>
        let isNegativeDataEmpty: Observable<Bool>
        let isOtherDataEmpty: Observable<Bool>
        let itemToRemove: Observable<EditButtonCellModel>
    }
    
    private let bag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let symptomDataArr = BehaviorSubject<[SymptomData]>(
            value: SymptomDataManager.shared.read()
        )
                
        // 부작용 데이터 섹션 데이터로 바인딩
        let negativeSectionDataArr = Observable
            .combineLatest(symptomDataArr, input.isEditing)
            .map { dataArr, isEditing in
                dataArr.map { $0.updated(isEditMode: isEditing) }
                    .filter { $0.isNegative } // 부작용 필터링
                    .sectionDataArr // 섹션 데이터로 변경
            }
            
        // 기타 증상 데이터 섹션 데이터로 바인딩
        let otherSectionDataArr = Observable
            .combineLatest(symptomDataArr, input.isEditing)
            .map { dataArr, isEditing in
                dataArr.map { $0.updated(isEditMode: isEditing) }
                    .filter { !$0.isNegative } // 기타 증상 필터링
                    .sectionDataArr // 섹션 데이터로 변경
            }
        
        // 데이터 리로드 요청 시, 데이터 재요청
        input.reloadEvent
            .map { _ in SymptomDataManager.shared.read() }
            .bind(to: symptomDataArr)
            .disposed(by: bag)
        
        // 셀 데이터가 비어있으면, 대체 화면 표시
        let isNegativeDataEmpty = negativeSectionDataArr
            .map { $0.cellDataArr.isEmpty }
        let isOtherDataEmpty = otherSectionDataArr
            .map { $0.cellDataArr.isEmpty }
        
        // 편집 상태일 때, 삭제할 아이템 전달
        let itemToRemove = input.selectedModel
            .withLatestFrom(input.isEditing) { $1 ? $0 : nil }
            .compactMap { $0 }
        
        return Output(
            negativeSectionDataArr: negativeSectionDataArr,
            otherSectionDataArr: otherSectionDataArr,
            reloadEvent: input.reloadEvent,
            isNegativeDataEmpty: isNegativeDataEmpty,
            isOtherDataEmpty: isOtherDataEmpty,
            itemToRemove: itemToRemove
        )
    }
}

