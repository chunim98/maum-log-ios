//
//  TrendCalendarView.swift
//  MaumLog
//
//  Created by 신정욱 on 12/5/24.
//

import UIKit

final class TrendCalendarView: UICalendarView {
    private var calendarDataDic = [DateComponents : Int]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        wantsDateDecorations = true
        fontDesign = .rounded
        tintColor = .chuTint
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadDecorations(calendarDataDic: [DateComponents : Int]) {
        self.calendarDataDic = calendarDataDic
        let dates = Array(calendarDataDic.keys)
        super.reloadDecorations(forDateComponents: dates, animated: true)
    }
}

extension TrendCalendarView: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        // 일치하는 날짜에 value값이 있는지 확인, 없으면 nil
        let rate = calendarDataDic.first { key, _ in
            if key.year == dateComponents.year,
               key.month == dateComponents.month,
               key.day == dateComponents.day {
                return true
            } else {
                return false
            }
        }
        
        guard let rate = rate?.value else { return nil }
        // 커스텀 라벨 미리 구현, 나중에 디테일한 구현 필요하면 컴포넌트에 사전 선언하는걸로
        let label = UILabel()
        label.text = rate.toNegativeName
        label.textColor = .chuBlack
        label.font = .boldSystemFont(ofSize: 12)
        return UICalendarView.Decoration.customView { return label }
    }
}
