//
//  AddLogVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/6/24.
//

import UIKit
import RxSwift

final class AddLogVM {
    
    private let bag = DisposeBag()
    
    let input: Input
    let output: Output

    struct Input {
        let addPendingLog: AnyObserver<SymptomCardData>
        let removePendingLogByIndex: AnyObserver<Int>
        let updateRate: AnyObserver<(index: Int, rate: Int)>
        let tappedConfirmButton: AnyObserver<Void>
        let saveByLogData: AnyObserver<Void>
        let tappedCloseButton: AnyObserver<Void>
    }
    
    struct Output {
        let negativeData: Observable<[SymptomData]>
        let otherData: Observable<[SymptomData]>
        let isSymptomDataEmpty: Observable<(Bool, Bool)>
        let pendingLogData: Observable<[SymptomCardData]>
        let isPendingLogEmpty: Observable<Bool>
        let isEnabledConfirmButton: Observable<Bool>
        let isEnabledModalGesture: Observable<Bool>
        let confirmWithDismiss: Observable<Void>
        let justDismiss: Observable<Void>
    }

    private let pendingLogDataSubject = BehaviorSubject<[SymptomCardData]>(value: [])
    private let addPendingLogSubject = PublishSubject<SymptomCardData>()
    private let removePendingLogSubject = PublishSubject<Int>()
    private let updateRateSubject = PublishSubject<(index: Int, rate: Int)>()
    private let confirmButtonSubject = PublishSubject<Void>()
    private let saveLogDataSubject = PublishSubject<Void>()
    private let closeButtonSubject = PublishSubject<Void>()

    
    init() {
        // 저장한 증상들 방출, 부작용
        let negativeData = Observable
            .just(SymptomDataManager.shared.read().filter { $0.isNegative }) // 부작용만 필터링
            .share(replay: 1)
        
        
        // 저장한 증상들 방출, 기타증상
        let otherData = Observable
            .just(SymptomDataManager.shared.read().filter { !($0.isNegative) }) // 기타증상만 필터링
            .share(replay: 1)
        
        
        // 등록된 증상 데이터가 없는지
        let isSymptomDataEmpty = Observable
            .combineLatest(negativeData, otherData)
            .map {
                let isNegativeEmpty = $0.isEmpty
                let isOtherEmpty = $1.isEmpty
                
                return (isNegativeEmpty, isOtherEmpty)
            }
            .share(replay: 1)
        

        // 리스트가 비었다면 추가버튼 비활성화
        let isEnabledConfirmButton = pendingLogDataSubject
            .map { !($0.isEmpty) }
        
        
        // 리스트가 비었다면 모달 닫기 제스쳐 비활성화
        let isEnabledModalGesture = pendingLogDataSubject
            .map { !($0.isEmpty) }
        
        
        // 리스트가 비었다면 안내 문구 표시
        let isPendingLogEmpty = pendingLogDataSubject
            .map { $0.isEmpty }
        
        
        // 리스트의 임시 로그 추가
        addPendingLogSubject
            .withLatestFrom(pendingLogDataSubject) { data, dataArr in
                // 중복등록 막기
                let isDuplicateed = dataArr.contains {
                    ($0.name == data.name)&&($0.isNegative == data.isNegative)&&($0.hex == data.hex)
                }
                guard !(isDuplicateed) else { return dataArr }
                
                // 부작용, 기타증상 순으로 정렬시키기
                var negatives = dataArr.filter { $0.isNegative }
                var others = dataArr.filter { !($0.isNegative) }

                if data.isNegative {
                    negatives.append(data)
                } else {
                    others.append(data)
                }
                return negatives + others
            }
            .bind(to: pendingLogDataSubject)
            .disposed(by: bag)
        
        
        // 리스트의 임시 로그 삭제
        removePendingLogSubject
            .withLatestFrom(pendingLogDataSubject) {
                var array = $1
                array.remove(at: $0)
                return array
            }
            .bind(to: pendingLogDataSubject)
            .disposed(by: bag)
        
        
        // 리스트의 임시 로그 레이트 업뎃
        updateRateSubject
            .withLatestFrom(pendingLogDataSubject) {
                var array = $1
                array[$0.index].rate = $0.rate
                return array
            }
            .bind(to: pendingLogDataSubject)
            .disposed(by: bag)
        
        
        // 리스트의 임시 로그 메인 저장소에 저장
        saveLogDataSubject
            .take(1)
            .withLatestFrom(pendingLogDataSubject)
            .bind(onNext: {
                LogDataManager.shared.create(from: $0)
                HapticManager.shared.occurSuccess()
            })
            .disposed(by: bag)

        
        input = .init(
            addPendingLog: addPendingLogSubject.asObserver(), 
            removePendingLogByIndex: removePendingLogSubject.asObserver(), 
            updateRate: updateRateSubject.asObserver(), 
            tappedConfirmButton: confirmButtonSubject.asObserver(), 
            saveByLogData: saveLogDataSubject.asObserver(), 
            tappedCloseButton: closeButtonSubject.asObserver())
        
        output = .init(
            negativeData: negativeData, 
            otherData: otherData, 
            isSymptomDataEmpty: isSymptomDataEmpty,
            pendingLogData: pendingLogDataSubject.asObservable(), 
            isPendingLogEmpty: isPendingLogEmpty,
            isEnabledConfirmButton: isEnabledConfirmButton,
            isEnabledModalGesture: isEnabledModalGesture,
            confirmWithDismiss: confirmButtonSubject.asObservable(), 
            justDismiss: closeButtonSubject.asObservable())
    }
 
}
