//
//  AddMedicineCapsuleTextFieldVM.swift
//  MaumLog
//
//  Created by 신정욱 on 4/15/25.
//

import UIKit
import Combine

final class AddMedicineCapsuleTextFieldVM {
    
    struct Input { let text: AnyPublisher<String, Never> }
    struct Output { let clippedText: AnyPublisher<String, Never> }
    
    private var cancellables = Set<AnyCancellable>()
    
    func transform(_ input: Input) -> Output {
        
        // 무효한 공백 제거, 최대 12글자 제한
        let clippedText = input.text
            .map {
                let text = $0.trimmingCharacters(in: .whitespaces) // 공백 제거
                guard text.count > 12 else { return text }
                
                let i = text.index(text.startIndex, offsetBy: 12) // 13글자 지점의 인덱스
                return String(text[..<i])
            }
            .eraseToAnyPublisher()

        return Output(clippedText: clippedText)
    }
}
