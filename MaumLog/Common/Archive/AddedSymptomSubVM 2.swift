//
//  AddedSymptomSubVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/19/24.
//

import UIKit
import RxSwift
import RxCocoa

final class AddedSymptomSubVM2 {
    
    struct Input {
        let tappedAddButton: Observable<Void>
        let tappedEditButton: Observable<Void>
        let reloadCV: Observable<Void>
        let itemToRemove: Observable<EditButtonCellModel>
    }
    
    struct Output {
        let negativeCellDataArr: Observable<[SymptomSectionData]>
        let otherCellDataArr: Observable<[SymptomSectionData]>
        let goAddSymptom: Observable<Void>
        let isEditMode: Observable<Bool>
        let isDataEmpty: Observable<(Bool, Bool)>
        let needUpdateCV: Observable<Void>
        let presentRemoveAlert: Observable<EditButtonCellModel>
    }
    
    private let bag = DisposeBag()
    
    func transform(input: Input) -> Output {
        // 증상 데이터 상태를 가지는 서브젝트
        let cellDataArr = BehaviorSubject<[SymptomData]>(value: SymptomDataManager.shared.read())
        // 편집버튼 상태 서브젝트 ( 나중에 리펙터링 할 것 )
        let isEditMode = BehaviorSubject<Bool>(value: false)
        
        // AddSymptom 화면으로 이동
        let goAddSymptom = input.tappedAddButton
       
        // 편집모드 값 토글
        input.tappedEditButton
            .withLatestFrom(isEditMode) { _, isEditMode in
                HapticManager.shared.occurLight() // 진동 울리기
                return !isEditMode
            }
            .bind(to: isEditMode)
            .disposed(by: bag)
        
        // 토글된 값 적용, 부작용
        let negativeCellDataArr = Observable
            .combineLatest(cellDataArr, isEditMode)
            .map { dataArr, isEditMode in
                // 증상 데이터 안에 들어있는 편집모드 값을 외부 값으로 변경
                var dataArr = dataArr
                dataArr = dataArr.map {
                    var data = $0
                    data.isEditMode = isEditMode
                    return data
                }
                
                // 부작용만 필터링
                let negativeData = dataArr.filter { $0.isNegative }
                return [SymptomSectionData(items: negativeData)]
            }
            .share(replay: 1)
        
        // 토글된 값 적용, 기타증상
        let otherCellDataArr = Observable
            .combineLatest(cellDataArr, isEditMode)
            .map { dataArr, isEditMode in
                // 증상 데이터 안에 들어있는 편집모드 값을 외부 값으로 변경
                var dataArr = dataArr
                dataArr = dataArr.map {
                    var data = $0
                    data.isEditMode = isEditMode
                    return data
                }
                
                // 기타증상만 필터링
                let otherData = dataArr.filter { !($0.isNegative) }
                return [SymptomSectionData(items: otherData)]
            }
            .share(replay: 1)
        
        // 컬렉션뷰 리로드
        input.reloadCV
            .map { SymptomDataManager.shared.read() }
            .bind(to: cellDataArr)
            .disposed(by: bag)
                
        // 셀 데이터가 없는지 확인
        let isDataEmpty = cellDataArr
            .map {
                let isNegativeEmpty = $0.filter { $0.isNegative }.isEmpty
                let isOtherEmpty = $0.filter { !($0.isNegative) }.isEmpty
                
                return (isNegativeEmpty, isOtherEmpty)
            }
            .share(replay: 1)
        
        let presentRemoveAlert = input.itemToRemove
        
        let needUpdateCV = input.reloadCV

        
        
        return Output(
            negativeCellDataArr: negativeCellDataArr,
            otherCellDataArr: otherCellDataArr,
            goAddSymptom: goAddSymptom,
            isEditMode: isEditMode.asObservable(),
            isDataEmpty: isDataEmpty,
            needUpdateCV: needUpdateCV,
            presentRemoveAlert: presentRemoveAlert)
    }

}
