//
//  AddSymptomVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa

final class AddSymptomVM {

    struct Input {
        let closeButtonEvent: Observable<AddSymptomEvent>
        let confirmButtonEvent: Observable<ConfirmButton.Event>
        let clippedText: Observable<String>
        let selectedColor: Observable<UIColor>
    }
    
    struct Output {
        let isConfirmButtonEnabled: Observable<Bool>
        let addSymptomEvent: Observable<AddSymptomEvent>
        let selectedColor: Observable<UIColor>
    }
    
    private let bag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let symptomDataArr = BehaviorSubject(value: SymptomDataManager.shared.read())
        
        // 텍스트 필드가 채워지면, 추가 버튼 활성화
        let isEnabledConfirmButton = input.clippedText
            .map { !$0.isEmpty }

        // 확인 버튼이 눌렸을 때, 데이터의 중복 여부에 따라 다른 이벤트 방출
        let saveOrAlertEvent = input.confirmButtonEvent
            .withLatestFrom(Observable.combineLatest(
                input.selectedColor.startWith(.chuTint),
                input.clippedText,
                symptomDataArr
            )) { ($0, $1.0, $1.1, $1.2) }
            .flatMap(attemptToAddSymptom)
        
        return Output(
            isConfirmButtonEnabled: isEnabledConfirmButton,
            addSymptomEvent: Observable.merge(saveOrAlertEvent, input.closeButtonEvent),
            selectedColor: input.selectedColor
        )
    }
    
    // MARK: Methods
    
    private func attemptToAddSymptom(
        buttonEvent: ConfirmButton.Event,
        selectedColor: UIColor,
        clippedText: String,
        symptomDataArr: [SymptomData]
    ) -> Observable<AddSymptomEvent> {
        Observable.create { observer in
            guard !symptomDataArr.contains(where: { $0.name == clippedText }) else {
                observer.onNext(.presentDuplicateAlert(clippedText))
                return Disposables.create()
            }

            let symptomData = SymptomData(
                name: clippedText,
                hex: selectedColor.toHexInt,
                isNegative: buttonEvent == .negative
            )
            SymptomDataManager.shared.create(from: symptomData)
            observer.onNext(.save)
            
            return Disposables.create()
        }
    }
}
