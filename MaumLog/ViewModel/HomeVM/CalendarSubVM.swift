//
//  CalendarSubVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/20/24.
//

import UIKit
import RxSwift

final class CalendarSubVM {
    
    private let bag = DisposeBag()

    let input: Input
    let output: Output

    struct Input {
        let reloadCalender: AnyObserver<Void>
    }
    
    struct Output {
        let calenderData: Observable<[DateComponents : Int]>
        let targetReloadDate: Observable<[DateComponents]> // 달력 업데이트를 위한 [DateComponents]
    }
    
    
    private let calenderDataSubject = BehaviorSubject<[LogData]>(value: LogDataManager.shared.read())
    private let reloadSubject = PublishSubject<Void>()

    
    init() {
        // 달력에 쓸 레이트 값으로 만들기
        let calenderData = calenderDataSubject
            .map {
                let data = $0
                let grouped = Dictionary(grouping: data) { Calendar.current.dateComponents([.year, .month, .day], from: $0.date) } // 년, 월, 일 같은 애들 다 그룹핑
                let calendarData = grouped.mapValues { logDataArr in // 딕셔너리 벨류만 적용되는 map 고차함수
                    let symptomCardsArr = logDataArr.map { $0.symptomCards } // 증상카드 배열 자체가 없을 수도 있음( 추후 추가될 메모만 썼다던가? )
                    let symptomCards = symptomCardsArr.compactMap { $0 }.flatMap { $0 } // 컴팩맵으로 옵셔널 풀고 플랫으로 1차원으로 만듦
                    let rates = symptomCards.filter { $0.isNegative && $0.rate != 0 }.map { $0.rate } // 부작용 rate 뽑아오기, rate 0은 계산에 포함 안함
                    
                    // rates가 비었다면 0으로 나누게 되는 곤란한 상황을 막는 안전장치!
                    guard !(rates.isEmpty) else { return 0 }
                    
                    let averageRate = Double(rates.reduce(0) { $0 + $1 }) / Double(rates.count) // Int로 나누면 Int밖에 안나옴
                    let roundedAaverageRate = Int(round(averageRate)) // 반올림,내림 처리
                    return roundedAaverageRate
                }
                return calendarData
            }
            .share(replay: 1)
        
        
        // 달력 업데이트
        let reloadDate = reloadSubject
            .do(onNext: { [calenderDataSubject] _ in
                calenderDataSubject.onNext(LogDataManager.shared.read()) // 달력 새로운 값 방출
            })
            .map { // 업데이트 하고싶은 날짜가 담긴 DateComponents배열로 매핑, ±30일만 리로드
                let today = Date()
                let calendar = Calendar.current
                var dateComponents = [DateComponents]()
                
                // ±30일간의 DateComponents 생성
                for offset in -30...30 {
                    guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return [DateComponents]() }
                    let components = calendar.dateComponents([.year, .month, .day], from: date)
                    dateComponents.append(components)
                }
                return dateComponents
            }
            .share(replay: 1)

        
        input = .init(
            reloadCalender: reloadSubject.asObserver())
        
        output = .init(
            calenderData: calenderData,
            targetReloadDate: reloadDate)
    }
}
