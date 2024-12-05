//
//  MedicineSectionVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import RxSwift
import RxCocoa

final class MedicineSectionVM {

    struct Input {
        let tappedAddButton: Observable<Void>
        let tappedEditButton: Observable<Void>
        let reloadCV: Observable<Void>
        let itemToRemove: Observable<EditButtonCellModel>
    }
    
    struct Output {
        let cellData: Observable<[MedicineSectionData]>
        let goAddMedicine: Observable<Void>
        let isEditMode: Observable<Bool>
        let isDataEmpty: Observable<Bool>
        let needUpdateCV: Observable<Void>
        let presentRemoveMedicineAlert: Observable<EditButtonCellModel>
    }
    
    private let bag = DisposeBag()

    func transform(_ input: Input) -> Output {
        // 약물 데이터
        let cellDataArr = BehaviorSubject<[MedicineData]>(value: MedicineDataManager.shared.read())
        // 편집버튼 상태
        let isEditMode = BehaviorSubject<Bool>(value: false)
        
        // 편집모드 값 토글
        input.tappedEditButton
            .withLatestFrom(isEditMode) { _, isEditMode in
                HapticManager.shared.occurLight() // 진동 울리기
                return !isEditMode
            }
            .bind(to: isEditMode)
            .disposed(by: bag)
        
        // 토글된 값 적용, 부작용
        let cellData = Observable
            .combineLatest(cellDataArr, isEditMode)
            .map { data, isEdit in
                // 증상 데이터 안에 들어있는 편집모드 값을 외부 값으로 변경
                var cellData = data
                cellData = cellData.map {
                    var datum = $0
                    datum.isEditMode = isEdit
                    return datum
                }
                
                return [MedicineSectionData(items: cellData)]
            }
            .share(replay: 1)
        
        // 약물 추가 모달 띄우기
        let goAddMedicine = input.tappedAddButton
        
        // 컬렉션뷰 리로드
        input.reloadCV
            .map { MedicineDataManager.shared.read() }
            .bind(to: cellDataArr)
            .disposed(by: bag)
        
        // 셀 데이터가 없는지 확인
        let isDataEmpty = cellDataArr
            .map { $0.isEmpty }
            .share(replay: 1)
        
        let needUpdateCV = input.reloadCV
        
        let presentRemoveMedicineAlert = input.itemToRemove
        
        return Output(
            cellData: cellData,
            goAddMedicine: goAddMedicine,
            isEditMode: isEditMode.asObservable(),
            isDataEmpty: isDataEmpty,
            needUpdateCV: needUpdateCV,
            presentRemoveMedicineAlert: presentRemoveMedicineAlert)
    }
}

