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
        let buttonEvent: Observable<LogVCButtonEvent>
        let reloadEvent: Observable<Void>
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
        
        // 버튼 이벤트 분기한 프로퍼티
        let sortByDescendingEvent = input.buttonEvent.filter { $0 == .sortByDescending }
        let sortByAscendingEvent = input.buttonEvent.filter { $0 == .sortByAscending }
        let pushAddLogEvent_ = input.buttonEvent.filter { $0 == .pushAddLog }
        let intakeEvent = input.buttonEvent.filter { $0 == .intake }
        let editEvent = input.buttonEvent.filter { $0 == .edit }

        // 로그 테이블 뷰 리로드
        input.reloadEvent
            .map { LogDataManager.shared.read() }
            .bind(to: logDataArr)
            .disposed(by: bag)
        
        // 기록이 없다면 백그라운드 뷰 표시
        let isDataEmpty = logDataArr
            .map { $0.isEmpty }
        
        // 편집 모드 상태 전환
        editEvent
            .withLatestFrom(isEditing) { _, bool in !bool }
            .bind(to: isEditing)
            .disposed(by: bag)
        
        // 오름차 순 정렬
        sortByAscendingEvent
            .map { _ in false }
            .do(onNext: { SettingValuesStorage.shared.isAscendingOrder = $0 }) // 설정값 보존
            .bind(to: isAscendingOrder)
            .disposed(by: bag)
        
        // 내림차 순 정렬
        sortByDescendingEvent
            .map { _ in true }
            .do(onNext: { SettingValuesStorage.shared.isAscendingOrder = $0 }) // 설정값 보존
            .bind(to: isAscendingOrder)
            .disposed(by: bag)
        
        // 로그, 편집, 정렬 상태를 조합해서 sectionData로 만듦
        let logSectionDataArr = Observable
            .combineLatest(logDataArr, isEditing, isAscendingOrder)
            .compactMap { [weak self] in self?.getLogSectionDataArr($0, $1, $2) }
        
        // 기록 추가 모달 띄우기
        let pushAddLogEvent = pushAddLogEvent_
            .filter { _ in !(SymptomDataManager.shared.read().isEmpty) }
            .map { _ in }
        
        // 등록한 증상이 없다면 증상 부터 등록하라는 얼럿 띄우기
        let presentShouldAddSymptomAlertEvent = pushAddLogEvent_
            .filter { _ in SymptomDataManager.shared.read().isEmpty }
            .map { _ in }
        
        // 등록한 약이 없다면 먼저 등록부터 하라는 얼럿 띄우기
        let presentShouldAddMedicineAlertEvent = intakeEvent
            .filter { _ in MedicineDataManager.shared.read().isEmpty }
            .map { _ in }
        
        // 약물 섭취 기록 추가 (등록된 약이 있을 경우에만)
        intakeEvent
            .compactMap { [weak self] _ in self?.appendMedicineLog() }
            .bind(to: logDataArr)
            .disposed(by: bag)
        
        // 약 먹었다는 얼럿 띄우기 (등록된 약이 있을 경우에만)
        let presentTakeMedicineAlertEvent = intakeEvent
            .filter { _ in !(MedicineDataManager.shared.read().isEmpty) }
            .map { _ in }

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
    
    // MARK: Methods
    
    private func getLogSectionDataArr(
        _ logDataArr: [LogData],
        _ isEditing: Bool,
        _ isAscending: Bool
    ) -> [LogSectionData] {
        Dictionary(
            grouping: logDataArr.map { $0.updated(isEditMode: isEditing) } // 편집 상태 반영
        ) {
            // 문자열화 된 날짜 기준 그루핑 (헤더로 사용할거라 DateComponant는 사용불가)
            DateFormatter.forSort.string(from: $0.date)
        }.map {
            let items = isAscending ? $1.reversed() : $1 // 내부 데이터도 정렬
            return LogSectionData(items: items, dateForSorting: $0)
        }.sorted {
            isAscending ? ($0 < $1) : ($0 > $1)
        }
    }
    
    private func appendMedicineLog() -> [LogData]? {
        let mediData = MedicineDataManager.shared.read()
        guard !mediData.isEmpty else { return nil }
        
        let mediCardData = mediData.map { MedicineCardData(name: $0.name) }
        LogDataManager.shared.create(from: mediCardData)
        
        return LogDataManager.shared.read() // 업데이트가 반영된 값 불러오기
    }
}
