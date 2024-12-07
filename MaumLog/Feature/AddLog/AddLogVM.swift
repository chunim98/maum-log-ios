//
//  AddLogVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/6/24.
//

import UIKit
import RxSwift
import RxCocoa

final class AddLogVM {

    struct Input {
        let addPendingLog: Observable<SymptomCardData>
        let removePendingLogByIndex: Observable<Int>
        let updateRate: Observable<(index: Int, rate: Int)>
        let tappedConfirmButton: Observable<Void>
        let tappedCloseButton: Observable<Void>
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
    
    private let bag = DisposeBag()

    func transform(_ input: Input) -> Output {
        let pendingLogDataSubject = BehaviorSubject<[SymptomCardData]>(value: [])
        
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
        input.addPendingLog
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
        input.removePendingLogByIndex
            .withLatestFrom(pendingLogDataSubject) {
                var array = $1
                array.remove(at: $0)
                return array
            }
            .bind(to: pendingLogDataSubject)
            .disposed(by: bag)
        
        // 리스트의 임시 로그 레이트 업뎃
        input.updateRate
            .withLatestFrom(pendingLogDataSubject) {
                var array = $1
                array[$0.index].rate = $0.rate
                return array
            }
            .bind(to: pendingLogDataSubject)
            .disposed(by: bag)
        
        // 리스트의 계류 로그 메인 저장소에 저장하고 화면 닫기
        let confirmWithDismiss = input.tappedConfirmButton
            .take(1)
            .withLatestFrom(pendingLogDataSubject)
            .map { pendingLogData in
                LogDataManager.shared.create(from: pendingLogData)
                HapticManager.shared.occurSuccess()
            }
        
        // 그냥 화면 닫기
        let justDismiss = input.tappedCloseButton
        
        
        return Output(
            negativeData: negativeData,
            otherData: otherData,
            isSymptomDataEmpty: isSymptomDataEmpty,
            pendingLogData: pendingLogDataSubject.asObservable(),
            isPendingLogEmpty: isPendingLogEmpty,
            isEnabledConfirmButton: isEnabledConfirmButton,
            isEnabledModalGesture: isEnabledModalGesture,
            confirmWithDismiss: confirmWithDismiss,
            justDismiss: justDismiss)
    }
}
