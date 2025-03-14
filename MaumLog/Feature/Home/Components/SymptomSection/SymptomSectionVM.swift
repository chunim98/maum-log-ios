//
//  SymptomSectionVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/19/24.
//

import UIKit

import RxSwift
import RxCocoa

final class SymptomSectionVM {
    
    struct Input { let editButtonTapEvent: Observable<Void> }
    struct Output { let isEditing: Observable<Bool> }
    
    private let bag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let isEditing = BehaviorSubject<Bool>(value: false)
        
        // 편집 상태 반전
        input.editButtonTapEvent
            .do(onNext: { HapticManager.shared.occurLight() }) // 햅틱
            .withLatestFrom(isEditing) { _, bool in !bool }
            .bind(to: isEditing)
            .disposed(by: bag)
        
        return Output(isEditing: isEditing.asObservable())
    }
}
