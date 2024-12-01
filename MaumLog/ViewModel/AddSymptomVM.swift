//
//  AddSymptomVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/12/24.
//

import UIKit
import RxSwift

final class AddSymptomVM {
    
    let input: Input
    let output: Output

    struct Input {
        let tappedNegativeConfirmButton: AnyObserver<Void>
        let tappedOtherConfirmButton: AnyObserver<Void>
        let textOfTextField: AnyObserver<String>
        let tappedCloseButton: AnyObserver<Void>
    }
    
    struct Output {
        let colorPaletteData: Observable<[Int]>
        let negativeConfirmWithIsDuplicated: Observable<Bool>
        let otherConfirmWithIsDuplicated: Observable<Bool>
        let clippedText: Observable<String>
        let isEnabledConfirmButton: Observable<Bool>
        let justDismiss: Observable<Void>
        let setDefaultColor: Observable<UIColor>
    }
    
    // in out 처리하는 서브젝트
    private let negativeConfirmButtonSubject = PublishSubject<Void>()
    private let otherConfirmButtonSubject = PublishSubject<Void>()
    private let textFieldSubject = PublishSubject<String>()
    private let isEnabledConfirmButtonSubject = PublishSubject<Bool>()
    private let closeButtonSubject = PublishSubject<Void>()
    
    
    init() {
        let colorPalette = [0x6d6a74, 0x8e8a95, 0xb2b8c0, 0x6a5976, 0xd1b8b4, 0xd4c6c3, 0xd6c9c6, 0x9c7f8a, 0xdca46d, 0xc48b6d, 0x8d8a95, 0x7d676a,
                            0x5f5a64, 0x8c7d8a, 0xb1a5b1, 0xb9b5bf, 0xd2b5b5, 0xdfc7c4, 0xd4b8a6, 0x8e7d7b, 0x7b6d71, 0xa28d8d, 0x7f6f7b, 0x6b5a6b,
                            0x9d7a73, 0xb4a79b, 0x6b6f43, 0x8a8c5e, 0x9a9e71, 0xb4b86e]
        
        
        // 정해진 팔레트 방출
        let colorPaletteData = Observable
            .just(colorPalette)
            .share(replay: 1)
        
        
        // 8글자 제한해서 방출하는 observable
        let clippedTextofTextField = textFieldSubject
            .map {
                let text = $0.trimmingCharacters(in: .whitespaces)
                
                if text.count > 8 { // 텍스트 8글자 제한
                    let index = text.index(text.startIndex, offsetBy: 8)
                    return String(text[..<index])
                }else{
                    return text
                }
            }
            // self 호출을 피하기 위해 값 복사 캡쳐 (짜피 참조타입이라 값 복사해도 괜춘)
            .do(onNext: { [isEnabledConfirmButtonSubject] in isEnabledConfirmButtonSubject.onNext( !($0.isEmpty) ) }) // 추가버튼 활성화 여부 방출
            .share(replay: 1)
        
        
        // 중복된 이름인지 체크
        let isDuplicated = textFieldSubject
            .map { text in
                SymptomDataManager.shared.read().contains { $0.name == text }
            }
            .share(replay: 1)
        
        
        // 중복인지 같이 담아서 전송
        let negativeConfirmWithIsDuplicated = negativeConfirmButtonSubject
            .withLatestFrom(isDuplicated)
            .map { $0 }
            .share(replay: 1)
        
        
        // 중복인지 같이 담아서 전송
        let otherConfirmWithIsDuplicated = otherConfirmButtonSubject
            .withLatestFrom(isDuplicated)
            .map { $0 }
            .share(replay: 1)
        
        
        // 추가화면을 열었을 때 랜덤한 색상이 선택되어 있게 함
        let setDefaultColor = Observable
            .just(colorPalette.randomElement()!.toUIColor)
            .share(replay: 1)

        

        input = .init(
            tappedNegativeConfirmButton: negativeConfirmButtonSubject.asObserver(),
            tappedOtherConfirmButton: otherConfirmButtonSubject.asObserver(),
            textOfTextField: textFieldSubject.asObserver(),
            tappedCloseButton: closeButtonSubject.asObserver())
        
        output = .init(
            colorPaletteData: colorPaletteData,
            negativeConfirmWithIsDuplicated: negativeConfirmWithIsDuplicated,
            otherConfirmWithIsDuplicated: otherConfirmWithIsDuplicated,
            clippedText: clippedTextofTextField,
            isEnabledConfirmButton: isEnabledConfirmButtonSubject.asObservable(), 
            justDismiss: closeButtonSubject.asObservable(), 
            setDefaultColor: setDefaultColor)
    }
}
