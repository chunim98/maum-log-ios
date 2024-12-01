//
//  AddedSymptomSubVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/19/24.
//

import UIKit
import RxSwift

final class AddedSymptomSubVM {
    
    private let bag = DisposeBag()

    let input: Input
    let output: Output

    struct Input {
        let tappedAddButton: AnyObserver<Void>
        let tappedEditButton: AnyObserver<Void>
        let reloadCV: AnyObserver<Void>
    }
    
    struct Output {
        let negativeCellData: Observable<[SymptomSectionData]>
        let otherCellData: Observable<[SymptomSectionData]>
        let goAddSymptom: Observable<Void>
        let isEditMode: Observable<Bool>
        let isDataEmpty: Observable<(Bool, Bool)>
    }
    
    
    private let cellDataSubject = BehaviorSubject<[SymptomData]>(value: SymptomDataManager.shared.read()) // 증상 데이터 상태를 가지는 섭젝
    private let isEditModeSubject = BehaviorSubject<Bool>(value: false) // 편집버튼 상태만 바꿔주는 용도 ( 나중에 리펙터링 할 것 )
    private let addButtonSubject = PublishSubject<Void>()
    private let editButtonSubject = PublishSubject<Void>()
    private let reloadCVSubject = PublishSubject<Void>() // 증상 컬렉션뷰 리로드 이벤트를 처리하기 위한 섭젝

    
    init() {
        // 편집모드 값 토글
        editButtonSubject
            .withLatestFrom(isEditModeSubject)
            .map {
                HapticManager.shared.occurLight() // 진동 울리기
                return !$0
            }
            .bind(to: isEditModeSubject)
            .disposed(by: bag)
        
        
        // 토글된 값 적용, 부작용
        let negativeCellData = Observable
            .combineLatest(cellDataSubject, isEditModeSubject)
            .map { data, isEdit in
                // 증상 데이터 안에 들어있는 편집모드 값을 외부 값으로 변경
                var cellData = data
                cellData = cellData.map {
                    var datum = $0
                    datum.isEditMode = isEdit
                    return datum
                }
                
                // 부작용만 필터링
                let negativeData = cellData.filter { $0.isNegative }
                return [SymptomSectionData(items: negativeData)]
            }
            .share(replay: 1)
        
        
        // 토글된 값 적용, 기타증상
        let otherCellData = Observable
            .combineLatest(cellDataSubject, isEditModeSubject)
            .map { data, isEdit in
                // 증상 데이터 안에 들어있는 편집모드 값을 외부 값으로 변경
                var cellData = data
                cellData = cellData.map {
                    var datum = $0
                    datum.isEditMode = isEdit
                    return datum
                }
                
                // 기타증상만 필터링
                let otherData = cellData.filter { !($0.isNegative) }
                return [SymptomSectionData(items: otherData)]
            }
            .share(replay: 1)

        
        // 컬렉션뷰 리로드
        reloadCVSubject
            .map { SymptomDataManager.shared.read() }
            .bind(to: cellDataSubject)
            .disposed(by: bag)
        
        
        // 셀 데이터가 없는지
        let isDataEmpty = cellDataSubject
            .map {
                let isNegativeEmpty = $0.filter { $0.isNegative }.isEmpty
                let isOtherEmpty = $0.filter { !($0.isNegative) }.isEmpty
                
                return (isNegativeEmpty, isOtherEmpty)
            }
            .share(replay: 1)



        input = .init(
            tappedAddButton: addButtonSubject.asObserver(),
            tappedEditButton: editButtonSubject.asObserver(),
            reloadCV: reloadCVSubject.asObserver())
        
        output = .init(
            negativeCellData: negativeCellData, 
            otherCellData: otherCellData,
            goAddSymptom: addButtonSubject.asObservable(),
            isEditMode: isEditModeSubject.asObservable(),
            isDataEmpty: isDataEmpty)
    }

}
