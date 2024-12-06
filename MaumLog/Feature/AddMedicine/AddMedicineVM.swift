//
//  AddMedicineVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import RxSwift
import RxCocoa

final class AddMedicineVM {
    
    struct Input {
        let tappedConfirmButton: Observable<Void>
        let textOfTextField: Observable<String>
        let tappedCloseButton: Observable<Void>
    }
    
    struct Output {
        let clippedText: Observable<String>
        let isEnabledConfirmButton: Observable<Bool>
        let justDismiss: Observable<Void>
        let presentDuplicateAlert: Observable<String>
        let saveAndDismiss: Observable<Void>
    }
    
    private let bag = DisposeBag()
    
//    // in out 처리하는 서브젝트
//    private let confirmButtonSubject = PublishSubject<Void>()
//    private let textFieldSubject = PublishSubject<String>()
//    private let isEnabledConfirmButtonSubject = PublishSubject<Bool>()
//    private let closeButtonSubject = PublishSubject<Void>()
    
    func transform(_ input: Input) -> Output {
        // 중복 얼럿 메시지 전송
        let presentDuplicateAlert = PublishSubject<String>()
        // 저장 후 화면 닫기 메시지 전송
        let saveAndDismiss = PublishSubject<Void>()
        
        // MARK: - Observables
        // 텍스트 필드 12글자 제한
        let clippedText = input.textOfTextField
            .map {
                // 공백은 제거
                let text = $0.trimmingCharacters(in: .whitespaces)
                
                // 텍스트 8글자 제한
                if text.count > 12 {
                    let index = text.index(text.startIndex, offsetBy: 12)
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
        input.tappedConfirmButton
            .withLatestFrom(clippedText)
            .bind(with: self) { owner, name in
                let isDuplicated = owner.checkDuplicate(text: name)
                
                // 중복 체크 후 저장 or 중복 얼럿 띄우기
                if !isDuplicated {
                    MedicineDataManager.shared.create(from: MedicineData(name: name))
                    saveAndDismiss.onNext(())
                } else {
                    presentDuplicateAlert.onNext(name)
                }
            }
            .disposed(by: bag)
        
        let justDismiss = input.tappedCloseButton
        
        
        return Output(
            clippedText: clippedText,
            isEnabledConfirmButton: isEnabledConfirmButton,
            justDismiss: justDismiss,
            presentDuplicateAlert: presentDuplicateAlert.asObservable(),
            saveAndDismiss: saveAndDismiss.asObservable())
    }
    
    // MARK: - Methods
    private func checkDuplicate(text: String) -> Bool {
        MedicineDataManager.shared.read().contains { $0.name == text }
    }
    
//    init() {
//
//        // 12글자 제한해서 방출하는 observable
//        let clippedTextofTextField = textFieldSubject
//            .map {
//                let text = $0.trimmingCharacters(in: .whitespaces)
//                
//                if text.count > 12 { // 텍스트 12글자 제한
//                    let index = text.index(text.startIndex, offsetBy: 12)
//                    return String(text[..<index])
//                } else {
//                    return text
//                }
//            }
//            // self 호출을 피하기 위해 값 복사 캡쳐 (짜피 참조타입이라 값 복사해도 괜춘)
//            .do(onNext: { [isEnabledConfirmButtonSubject] in isEnabledConfirmButtonSubject.onNext( !($0.isEmpty) ) }) // 추가버튼 활성화 여부 방출
//            .share(replay: 1)
//        
//        
//        // 중복된 이름인지 체크
//        let isDuplicated = textFieldSubject
//            .map { text in
//                MedicineDataManager.shared.read().contains { $0.name == text }
//            }
//            .share(replay: 1)
//        
//        
//        // 중복인지 같이 담아서 전송
//        let confirmWithIsDuplicated = confirmButtonSubject
//            .withLatestFrom(isDuplicated)
//            .map { $0 }
//            .share(replay: 1)
//
//        
//
//        input = .init(
//            tappedConfirmButton: confirmButtonSubject.asObserver(),
//            textOfTextField: textFieldSubject.asObserver(),
//            tappedCloseButton: closeButtonSubject.asObserver())
//        
//        output = .init(
//            confirmWithIsDuplicated: confirmWithIsDuplicated,
//            clippedText: clippedTextofTextField,
//            isEnabledConfirmButton: isEnabledConfirmButtonSubject.asObservable(),
//            justDismiss: closeButtonSubject.asObservable())
//    }
}
