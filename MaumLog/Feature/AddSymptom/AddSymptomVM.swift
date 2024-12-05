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
        let tappedNegativeConfirmButton: Observable<Void>
        let tappedOtherConfirmButton: Observable<Void>
        let textOfTextField: Observable<String>
        let tappedCloseButton: Observable<Void>
        let selectedColorFromPalette: Observable<UIColor>
        let selectedColorFromPicker: Observable<UIColor>
    }
    
    struct Output {
        let colorPaletteData: Observable<[Int]>
        let clippedText: Observable<String>
        let isEnabledConfirmButton: Observable<Bool>
        let justDismiss: Observable<Void>
        let selectedColor: Observable<UIColor>
        let presentDuplicateAlert: Observable<String>
        let saveAndDismiss: Observable<Void>
    }
    
    private let bag = DisposeBag()
    private let colorPalette = [
        0x6d6a74, 0x8e8a95, 0xb2b8c0, 0x6a5976, 0xd1b8b4, 0xd4c6c3,
        0xd6c9c6, 0x9c7f8a, 0xdca46d, 0xc48b6d, 0x8d8a95, 0x7d676a,
        0x5f5a64, 0x8c7d8a, 0xb1a5b1, 0xb9b5bf, 0xd2b5b5, 0xdfc7c4,
        0xd4b8a6, 0x8e7d7b, 0x7b6d71, 0xa28d8d, 0x7f6f7b, 0x6b5a6b,
        0x9d7a73, 0xb4a79b, 0x6b6f43, 0x8a8c5e, 0x9a9e71, 0xb4b86e]
    
    func transform(_ input: Input) -> Output {
        // 중복 얼럿 메시지 전송
        let presentDuplicateAlert = PublishSubject<String>()
        // 저장 후 화면 닫기 메시지 전송
        let saveAndDismiss = PublishSubject<Void>()
        // randomElement가 nil일 수가 없음
        let selectedColor = BehaviorSubject(value: colorPalette.randomElement()!.toUIColor)

        // MARK: - Observables
        // 컬러 팔레트 데이터
        let colorPaletteData = Observable.just(colorPalette)
        
        // 텍스트 필드 8글자 제한
        let clippedText = input.textOfTextField
            .map {
                // 공백은 제거
                let text = $0.trimmingCharacters(in: .whitespaces)
                
                // 텍스트 8글자 제한
                if text.count > 8 {
                    let index = text.index(text.startIndex, offsetBy: 8)
                    return String(text[..<index])
                } else {
                    return text
                }
            }
            .share(replay: 1)
        
        // 텍스트 필드에 뭐라도 쳐야 추가버튼 활성화
        let isEnabledConfirmButton = clippedText
            .map { !($0.isEmpty) }
        
        // 저장 버튼 눌렀을 때의 저장 로직
        Observable
            .merge( // Bool타입으로 변환해서 어떤 버튼이 눌렸는지 구분
                input.tappedNegativeConfirmButton.map { true },
                input.tappedOtherConfirmButton.map { false })
            .withLatestFrom(Observable.combineLatest(clippedText, selectedColor)) { isNegative, combined in
                let (clippedText, selectedColor) = combined
                return SymptomData(name: clippedText, hex: selectedColor.toHexInt, isNegative: isNegative)
            }
            .bind(with: self) { owner, symptomData in
                let isDuplicated = owner.checkDuplicate(text: symptomData.name)
                
                // 중복 체크 후 저장 or 중복 얼럿 띄우기
                if !isDuplicated {
                    SymptomDataManager.shared.create(from: symptomData)
                    saveAndDismiss.onNext(())
                } else {
                    presentDuplicateAlert.onNext(symptomData.name)
                }
            }
            .disposed(by: bag)

        // 화면 닫기 메시지 전송
        let justDismiss = input.tappedCloseButton
        
        // 선택한 색상 업데이트
        Observable
            .merge(input.selectedColorFromPalette, input.selectedColorFromPicker)
            .bind(to: selectedColor)
            .disposed(by: bag)
        
        return Output(
            colorPaletteData: colorPaletteData,
            clippedText: clippedText,
            isEnabledConfirmButton: isEnabledConfirmButton,
            justDismiss: justDismiss,
            selectedColor: selectedColor.asObservable(),
            presentDuplicateAlert: presentDuplicateAlert.asObservable(),
            saveAndDismiss: saveAndDismiss.asObservable())
    }
    
    // MARK: - Methods
    private func checkDuplicate(text: String) -> Bool {
        SymptomDataManager.shared.read().contains { $0.name == text }
    }
}
