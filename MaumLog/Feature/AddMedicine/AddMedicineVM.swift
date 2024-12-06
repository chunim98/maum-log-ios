//
//  AddMedicineVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import RxSwift

final class AddMedicineVM {
    
    let input: Input
    let output: Output

    struct Input {
        let tappedConfirmButton: AnyObserver<Void>
        let textOfTextField: AnyObserver<String>
        let tappedCloseButton: AnyObserver<Void>
    }
    
    struct Output {
        let confirmWithIsDuplicated: Observable<Bool>
        let clippedText: Observable<String>
        let isEnabledConfirmButton: Observable<Bool>
        let justDismiss: Observable<Void>
    }
    
    // in out 처리하는 서브젝트
    private let confirmButtonSubject = PublishSubject<Void>()
    private let textFieldSubject = PublishSubject<String>()
    private let isEnabledConfirmButtonSubject = PublishSubject<Bool>()
    private let closeButtonSubject = PublishSubject<Void>()
    
    
    init() {

        // 12글자 제한해서 방출하는 observable
        let clippedTextofTextField = textFieldSubject
            .map {
                let text = $0.trimmingCharacters(in: .whitespaces)
                
                if text.count > 12 { // 텍스트 12글자 제한
                    let index = text.index(text.startIndex, offsetBy: 12)
                    return String(text[..<index])
                } else {
                    return text
                }
            }
            // self 호출을 피하기 위해 값 복사 캡쳐 (짜피 참조타입이라 값 복사해도 괜춘)
            .do(onNext: { [isEnabledConfirmButtonSubject] in isEnabledConfirmButtonSubject.onNext( !($0.isEmpty) ) }) // 추가버튼 활성화 여부 방출
            .share(replay: 1)
        
        
        // 중복된 이름인지 체크
        let isDuplicated = textFieldSubject
            .map { text in
                MedicineDataManager.shared.read().contains { $0.name == text }
            }
            .share(replay: 1)
        
        
        // 중복인지 같이 담아서 전송
        let confirmWithIsDuplicated = confirmButtonSubject
            .withLatestFrom(isDuplicated)
            .map { $0 }
            .share(replay: 1)

        

        input = .init(
            tappedConfirmButton: confirmButtonSubject.asObserver(),
            textOfTextField: textFieldSubject.asObserver(),
            tappedCloseButton: closeButtonSubject.asObserver())
        
        output = .init(
            confirmWithIsDuplicated: confirmWithIsDuplicated,
            clippedText: clippedTextofTextField,
            isEnabledConfirmButton: isEnabledConfirmButtonSubject.asObservable(),
            justDismiss: closeButtonSubject.asObservable())
    }
}
