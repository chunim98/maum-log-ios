//
//  HomeVM.swift
//  MaumLog
//
//  Created by 신정욱 on 7/28/24.
//

import UIKit
import RxSwift

final class HomeVM {
    // 서브 뷰모델
    let symptomsSubVM = AddedSymptomSubVM()
    let medicineSubVM = AddedMedicineSubVM()
    let calendarSubVM = CalendarSubVM()
    
    private let bag = DisposeBag()

    let input: Input
    let output: Output

    struct Input { // 모든 입력 이벤트를 전달받아오는 친구들, 그냥 뷰에서 발생한 이벤트 여기로 가지고 오는 용도
        let tappedGoSettingsButton: AnyObserver<Void>
        let startRefreshing: AnyObserver<Void>
    }
    
    struct Output {
        let goSettings: Observable<Void>
        let endRefreshing: Observable<Void>
    }
    
    
    private let goSettingsButtonSubject = PublishSubject<Void>()
    private let startRefreshingSubject = PublishSubject<Void>() // 리프레시 인풋 전용
    private let endRefreshingSubject = PublishSubject<Void>() // 리프레시 아웃풋 전용

    
    init() {
        // 리프레시 트리거 됨
        startRefreshingSubject
            .bind(onNext: { [symptomsSubVM, medicineSubVM, calendarSubVM, endRefreshingSubject] in
                // 그냥 리프레시 되는 기분을 내주기 위해 구현한 0.75초 지연 코드
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    symptomsSubVM.input.reloadCV.onNext(())
                    medicineSubVM.input.reloadCV.onNext(())
                    calendarSubVM.input.reloadCalender.onNext(())
                    endRefreshingSubject.onNext(())
                }
            })
            .disposed(by: bag)
        
        
        input = .init( // observer 기능만 분리 (onNext 밖에 못함)
            tappedGoSettingsButton: goSettingsButtonSubject.asObserver(),
            startRefreshing: startRefreshingSubject.asObserver())
        
        output = .init(
            goSettings: goSettingsButtonSubject.asObservable(), 
            endRefreshing: endRefreshingSubject.asObservable())
    }
    
}
