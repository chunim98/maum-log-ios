//
//  LogVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/4/24.
//

import UIKit
import RxSwift

final class LogVM {
    
    private let bag = DisposeBag()
    
    let input: Input
    let output: Output
    
    struct Input {
        let tappedAddButton: AnyObserver<Void>
        let reloadSectionData: AnyObserver<Void>
        let tappedEditButton: AnyObserver<Void>
        let tappedEditDoneButton: AnyObserver<Void>
        let changeSorting: AnyObserver<Bool>
        let tappedTakeMedicineButton: AnyObserver<Void>
        let takeMedicine: AnyObserver<Void>
    }
    
    struct Output {
        let goAddLog: Observable<Bool>
        let shouldAddSymptom: Observable<Bool>
        let sectionData: Observable<[LogSectionData]>
        let isEditMode: Observable<Bool>
        let isAscendingOrder: Observable<Bool>
        let logDataIsEmpty: Observable<Bool>
        let shouldAddMedicine: Observable<Bool>
    }
    
    
    // in out 처리하는 서브젝트
    private let addButtonSubject = PublishSubject<Void>()
    private let logDataSubject = BehaviorSubject<[LogData]>(value: LogDataManager.shared.read())
    private let reloadSectionDataSubject = PublishSubject<Void>()
    private let editModeSubject = BehaviorSubject<Bool>(value: false) // 편집모드 상태를 가지는 섭젝
    private let editButtonSubject = PublishSubject<Void>()
    private let editDoneButtonSubject = PublishSubject<Void>()
    private let isAscendingOrderSubject = BehaviorSubject<Bool>(value: SettingValuesStorage.shared.isAscendingOrder) // 오름차순 정렬 설정인가?
    private let takeMedicineButtonSubject = PublishSubject<Void>()
    private let takeMedicineSubject = PublishSubject<Void>()
    
    
    init() {
        // 리로드
        reloadSectionDataSubject
            .map { LogDataManager.shared.read() }
            .bind(to: logDataSubject)
            .disposed(by: bag)
        
        // 편집모드 시작
        editButtonSubject
            .map { true }
            .bind(to: editModeSubject)
            .disposed(by: bag)
        
        // 편집 완료
        editDoneButtonSubject
            .map { false }
            .bind(to: editModeSubject)
            .disposed(by: bag)
        
        // 정렬 이벤트 받아오고 저장
        isAscendingOrderSubject
            .bind(onNext: { SettingValuesStorage.shared.isAscendingOrder = $0 })
            .disposed(by: bag)
        
        // 하나도 기록한 게 없는지
        let logDataIsEmpty = logDataSubject
            .map { $0.isEmpty }
            .share(replay: 1)
        
        
        // 로그데이터, 편집모드 여부, 오름차 정렬 여부 조합해서 sectionData로 내보냄 (꽤 복잡하다)
        let sectionData = Observable
            .combineLatest(logDataSubject, editModeSubject, isAscendingOrderSubject)
            .map { data, editMode, isAscendingOrder in
                
                // 편집모드인지 아닌지 수정해주는 코드(기본값 false)
                let logData = data.map {
                    var log = $0
                    log.isEditMode = editMode
                    return log
                }
                
                // 포메터로 문자열화 된 날짜 기준 그루핑 (헤더로 사용할거라 DateComponant는 사용불가)
                let grouped = Dictionary(grouping: logData) { DateFormatter.forSort.string(from: $0.date) }
                var sectionData = grouped.map { LogSectionData(items: $1, dateForSorting: $0) } // 딕셔너리 map돌리기
                sectionData.sort() // 순서가 섞여있을테니 정렬(오름차순)
                
                if isAscendingOrder {
                    for i in 0..<sectionData.count {
                        sectionData[i].items.reverse() // 내림차순이었던 내부 데이터를 오름차순으로 변경
                    }
                }else{
                    sectionData.reverse() // 내림차순으로 정렬 (내부 데이터 내림차순)
                }
                return sectionData
            }
            .share(replay: 1) // 이전값 1개만 방출, 적어도 구독시점에 현재 값은 받아올 수 있어야해서 0은 안됨
        
        
        // 등록한 증상이 없다면 먼저 등록부터
        let goToAddVC = addButtonSubject
            .map { !(SymptomDataManager.shared.read().isEmpty) }
            .share(replay: 1)
        
        
        // 등록한 증상이 없다면 먼저 등록부터
        let shouldAddSymptom = addButtonSubject
            .map { SymptomDataManager.shared.read().isEmpty }
            .share(replay: 1)
        
        takeMedicineSubject
            .bind(onNext: { [logDataSubject] in
                let data = MedicineDataManager.shared.read()
                let mediCardData = data.map { MedicineCardData(name: $0.name) }
                LogDataManager.shared.create(from: mediCardData)
                logDataSubject.onNext(LogDataManager.shared.read())
            })
            .disposed(by: bag)
        
        // 등록한 약이 없다면 먼저 등록부터
        let shouldAddMedicine = takeMedicineButtonSubject
            .map { MedicineDataManager.shared.read().isEmpty }
            .share(replay: 1)
        
        
        
        input = .init(
            tappedAddButton: addButtonSubject.asObserver(),
            reloadSectionData: reloadSectionDataSubject.asObserver(),
            tappedEditButton: editButtonSubject.asObserver(), 
            tappedEditDoneButton: editDoneButtonSubject.asObserver(), 
            changeSorting: isAscendingOrderSubject.asObserver(), 
            tappedTakeMedicineButton: takeMedicineButtonSubject.asObserver(), 
            takeMedicine: takeMedicineSubject.asObserver())
        
        output = .init(
            goAddLog: goToAddVC,
            shouldAddSymptom: shouldAddSymptom,
            sectionData: sectionData, 
            isEditMode: editModeSubject.asObservable(), 
            isAscendingOrder: isAscendingOrderSubject.asObservable(), 
            logDataIsEmpty: logDataIsEmpty, 
            shouldAddMedicine: shouldAddMedicine)
    }
    
}
