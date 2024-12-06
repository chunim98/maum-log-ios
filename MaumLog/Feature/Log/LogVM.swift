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
        let tappedAddButton: Observable<Void>
        let reloadSectionData: Observable<Void>
        let tappedEditButton: Observable<Void>
        let tappedEditDoneButton: Observable<Void>
        let changeSorting: Observable<Bool>
        let tappedTakeMedicineButton: Observable<Void>
        let takeMedicine: Observable<Void>
    }
    
    struct Output {
        let goAddLog: Observable<Void>
        let shouldAddSymptom: Observable<Void>
        let sectionData: Observable<[LogSectionData]>
        let isEditMode: Observable<Bool>
        let isAscendingOrder: Observable<Bool>
        let logDataIsEmpty: Observable<Bool>
        let shouldAddMedicine: Observable<Bool>
    }
    
    private let bag = DisposeBag()
    
    func transform (_ input: Input) -> Output {
        // 로그 데이터
        let logData = BehaviorSubject<[LogData]>(value: LogDataManager.shared.read())
        // 정렬 설정 값
        let isAscendingOrder = BehaviorSubject<Bool>(value: SettingValuesStorage.shared.isAscendingOrder)
        
        // 로그 테이블 뷰 리로드
        input.reloadSectionData
            .map { LogDataManager.shared.read() }
            .bind(to: logData)
            .disposed(by: bag)
        
        // 하나도 기록한 게 없는지
        let logDataIsEmpty = logData
            .map { $0.isEmpty }
        
        // 편집 모드, 초기 값이 있어야 로그 리스트 표시 가능
        let isEditMode = Observable
            .merge(
                input.tappedEditButton.map { true },
                input.tappedEditDoneButton.map { false })
            .startWith(false)
            .share(replay: 1)
        
        // 정렬 변경
        input.changeSorting
            .bind(to: isAscendingOrder)
            .disposed(by: bag)
        
        // 정렬이 바뀌면 설정 값을 업데이트
        isAscendingOrder
            .bind(onNext: { SettingValuesStorage.shared.isAscendingOrder = $0 })
            .disposed(by: bag)
        
        // 로그데이터, 편집모드 여부, 오름차 정렬 여부 조합해서 sectionData로 내보냄 (꽤 복잡하다)
        let sectionData = Observable
            .combineLatest(logData, isEditMode, isAscendingOrder)
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
        let goAddLog = input.tappedAddButton
            .filter { !(SymptomDataManager.shared.read().isEmpty) }
        
        // 등록한 증상이 없다면 증상 부터 등록하라는 얼럿 띄우기
        let shouldAddSymptom = input.tappedAddButton
            .filter { SymptomDataManager.shared.read().isEmpty }
        
        input.takeMedicine
            .map {
                let data = MedicineDataManager.shared.read()
                let mediCardData = data.map { MedicineCardData(name: $0.name) }
                LogDataManager.shared.create(from: mediCardData)
                // 업데이트가 반영된 값 불러오기
                return LogDataManager.shared.read()
            }
            .bind(to: logData)
            .disposed(by: bag)
        
        // 등록한 약이 없다면 먼저 등록부터
        let shouldAddMedicine = input.tappedTakeMedicineButton
            .map { MedicineDataManager.shared.read().isEmpty }

        
        return Output(
            goAddLog: goAddLog,
            shouldAddSymptom: shouldAddSymptom,
            sectionData: sectionData,
            isEditMode: isEditMode,
            isAscendingOrder: isAscendingOrder.asObservable(),
            logDataIsEmpty: logDataIsEmpty,
            shouldAddMedicine: shouldAddMedicine)
    }
}
