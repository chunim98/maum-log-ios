//
//  CapsuleTextFieldVM.swift
//  MaumLog
//
//  Created by 신정욱 on 3/15/25.
//

import Foundation

import RxSwift
import RxCocoa

final class CapsuleTextFieldVM {
    
    struct Input { let text: Observable<String> }
    struct Output { let clippedText: Observable<String> }
    
    private let bag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        
        // 무효한 공백 제거, 최대 8글자 제한
        let clippedText = input.text
            .map {
                let text = $0.trimmingCharacters(in: .whitespaces) // 공백 제거
                guard text.count > 8 else { return text }
                
                let i = text.index(text.startIndex, offsetBy: 8) // 9글자 지점의 인덱스
                return String(text[..<i])
            }
        
        return Output(clippedText: clippedText)
    }
}
