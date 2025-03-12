//
//  LogVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/4/24.
//

import UIKit

import RxSwift
import RxCocoa

final class LogVM {

    struct Input {
        let barButtonEvent: Observable<BarButtonEvent>
        let reloadEvent: Observable<Void>
        let takeMedicineButtonTapEvent: Observable<Void>
        let itemToRemove: Observable<EditButtonCellModel>
    }
    
    struct Output {
        let pushAddLogEvent: Observable<Void>
        let presentShouldAddSymptomAlertEvent: Observable<Void>
        let logSectionDataArr: Observable<[LogSectionData]>
        let isEditing: Observable<Bool>
        let isAscendingOrder: Observable<Bool>
        let isDataEmpty: Observable<Bool>
        let presentShouldAddMedicineAlertEvent: Observable<Void>
        let presentTakeMedicineAlertEvent: Observable<Void>
        let itemToRemove: Observable<EditButtonCellModel>
    }
    
    private let bag = DisposeBag()
    
    func transform (_ input: Input) -> Output {
        let logDataArr = BehaviorSubject<[LogData]>(value: LogDataManager.shared.read())
        let isEditing = BehaviorSubject<Bool>(value: false)
        let isAscendingOrder = BehaviorSubject<Bool>(
            value: SettingValuesStorage.shared.isAscendingOrder
        )

        // 로그 테이블 뷰 리로드
        input.reloadEvent
            .map { LogDataManager.shared.read() }
            .bind(to: logDataArr)
            .disposed(by: bag)
        
        // 하나도 기록한 게 없는지
        let isDataEmpty = logDataArr
            .map { $0.isEmpty }
        
        // 편집 모드 상태 전환
        input.barButtonEvent
            .filter { $0 == .edit }
            .withLatestFrom(isEditing) { _, bool in !bool }
            .bind(to: isEditing)
            .disposed(by: bag)
        
        // 오름차 순 정렬
        input.barButtonEvent
            .compactMap { ($0 == .sortByAscending) ? false : nil }
            .do(onNext: { SettingValuesStorage.shared.isAscendingOrder = $0 }) // 설정값 보존
            .bind(to: isAscendingOrder)
            .disposed(by: bag)
        
        // 내림차 순 정렬
        input.barButtonEvent
            .compactMap { ($0 == .sortByDescending) ? true : nil }
            .do(onNext: { SettingValuesStorage.shared.isAscendingOrder = $0 }) // 설정값 보존
            .bind(to: isAscendingOrder)
            .disposed(by: bag)

        
        // 로그데이터, 편집모드 여부, 오름차 정렬 여부 조합해서 sectionData로 내보냄 (꽤 복잡하다)
        let logSectionDataArr = Observable
            .combineLatest(logDataArr, isEditing, isAscendingOrder)
            .map { data, editMode, isAscendingOrder in
                
                // 편집모드인지 아닌지 수정해주는 코드(기본값 false)
                let logData = data.map {
                    var log = $0
                    log.isEditMode = editMode
                    return log
                }
                
                // 포메터로 문자열화 된 날짜 기준 그루핑 (헤더로 사용할거라 DateComponant는 사용불가)
                let grouped = Dictionary(grouping: logData) { DateFormatter.forSort.string(from: $0.date) }
                // 딕셔너리 map돌리기
                var sectionData = grouped.map { LogSectionData(items: $1, dateForSorting: $0) }
                // 순서가 섞여있을테니 정렬(오름차순)
                sectionData.sort()
                
                if isAscendingOrder {
                    for i in 0..<sectionData.count {
                        // 내림차순이었던 내부 데이터를 오름차순으로 변경
                        sectionData[i].items.reverse()
                    }
                } else {
                    // 내림차순으로 정렬 (내부 데이터 내림차순)
                    sectionData.reverse()
                }
                
                return sectionData
            }
            .share(replay: 1)
        
        // 기록 추가 모달 띄우기
        let pushAddLogEvent = input.barButtonEvent
            .filter { ($0 == .pushAddLog) && !(SymptomDataManager.shared.read().isEmpty) }
            .map { _ in }
        
        // 등록한 증상이 없다면 증상 부터 등록하라는 얼럿 띄우기
        let presentShouldAddSymptomAlertEvent = input.barButtonEvent
            .filter { ($0 == .pushAddLog) && SymptomDataManager.shared.read().isEmpty }
            .map { _ in }
        
        // 등록한 약이 없다면 먼저 등록부터 하라는 얼럿 띄우기
        let presentShouldAddMedicineAlertEvent = input.takeMedicineButtonTapEvent
            .filter { MedicineDataManager.shared.read().isEmpty }
        
        // 약물 섭취 기록 추가 (등록된 약이 있을 경우에만)
        input.takeMedicineButtonTapEvent
            .filter { !(MedicineDataManager.shared.read().isEmpty) }
            .map {
                let data = MedicineDataManager.shared.read()
                let mediCardData = data.map { MedicineCardData(name: $0.name) }
                LogDataManager.shared.create(from: mediCardData)
                // 업데이트가 반영된 값 불러오기
                return LogDataManager.shared.read()
            }
            .bind(to: logDataArr)
            .disposed(by: bag)
        
        // 약 먹었다는 얼럿 띄우기 (등록된 약이 있을 경우에만)
        let presentTakeMedicineAlertEvent = input.takeMedicineButtonTapEvent
            .filter { !(MedicineDataManager.shared.read().isEmpty) }
        
        return Output(
            pushAddLogEvent: pushAddLogEvent,
            presentShouldAddSymptomAlertEvent: presentShouldAddSymptomAlertEvent,
            logSectionDataArr: logSectionDataArr,
            isEditing: isEditing,
            isAscendingOrder: isAscendingOrder.asObservable(),
            isDataEmpty: isDataEmpty,
            presentShouldAddMedicineAlertEvent: presentShouldAddMedicineAlertEvent,
            presentTakeMedicineAlertEvent: presentTakeMedicineAlertEvent,
            itemToRemove: input.itemToRemove
        )
    }
}
