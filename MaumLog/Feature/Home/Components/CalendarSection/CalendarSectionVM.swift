//
//  CalendarSectionVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/20/24.
//

import UIKit

import RxSwift
import RxCocoa

final class CalendarSectionVM {

    struct Input { let reloadEvent: Observable<Void> }
    struct Output { let calenderData: Observable<[DateComponents : Int]> }
    
    private let bag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        let calenderData = BehaviorSubject(value: getCalenderData())
        
        // 데이터 리로드 요청 시, 데이터 재요청
        input.reloadEvent
            .compactMap { [weak self] _ in self?.getCalenderData() }
            .bind(to: calenderData)
            .disposed(by: bag)
        
        return Output(calenderData: calenderData.asObservable())
    }
    
    // MARK: Methods
    
    private func getCalenderData() -> [DateComponents : Int] {
        Dictionary(grouping: LogDataManager.shared.read()) {
            Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
        }.mapValues { logDataArr in
            // 모든 부작용의 rate를 추출
            let rates = logDataArr
                .map { $0.symptomCards }
                .flatMap { $0 }
                .filter { $0.isNegative && ($0.rate != 0) }
                .map { $0.rate }
            
            let sum = Double(rates.reduce(0, +))
            let count = Double(rates.count)
            return (count == 0) ? 0 : Int(round(sum/count)) // 0으로 나눠야 할 경우, 0 반환
        }
    }
}
