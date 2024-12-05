//
//  CalendarSectionVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/20/24.
//

import UIKit
import RxSwift

final class CalendarSectionVM {

    struct Input {
        let reloadCalender: Observable<Void>
    }
    
    struct Output {
        let calenderData: Observable<[DateComponents : Int]>
    }
    
    private let bag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        // 달력을 업데이트 하는데 필요한 데이터
        let calenderData = input.reloadCalender
            .startWith(()) // 최초 실행 시 달력에 데이터는 표시해야 해서 초깃값은 필요
            .map {
                let data = LogDataManager.shared.read()
                
                // 년, 월, 일 같은 애들 다 그룹핑
                let grouped = Dictionary(grouping: data) { Calendar.current.dateComponents([.year, .month, .day], from: $0.date) }
                
                // 딕셔너리 벨류만 적용되는 map 고차함수
                let calendarData = grouped.mapValues { logDataArr in
                    
                    // 증상카드 배열 자체가 없을 수도 있음( 추후 추가될 메모만 썼다던가? )
                    let symptomCardsArr = logDataArr.map { $0.symptomCards }
                    // 컴팩맵으로 옵셔널 풀고 플랫으로 1차원으로 만듦
                    let symptomCards = symptomCardsArr.compactMap { $0 }.flatMap { $0 }
                    // 부작용 rate 뽑아오기, rate 0은 계산에 포함 안함
                    let rates = symptomCards.filter { $0.isNegative && $0.rate != 0 }.map { $0.rate }

                    // rates가 비었다면 0으로 나누게 되는 곤란한 상황을 막는 안전장치!
                    guard !(rates.isEmpty) else { return 0 }
                    
                    let averageRate = Double(rates.reduce(0) { $0 + $1 }) / Double(rates.count) // Int로 나누면 Int밖에 안나옴
                    // 반올림,내림 처리
                    return Int(round(averageRate))
                }
                return calendarData
            }
            .share(replay: 1)
        
        return Output(calenderData: calenderData)
    }
}
