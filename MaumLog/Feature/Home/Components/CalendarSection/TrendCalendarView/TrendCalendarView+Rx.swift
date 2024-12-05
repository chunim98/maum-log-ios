//
//  TrendCalendarView+Rx.swift
//  MaumLog
//
//  Created by 신정욱 on 12/5/24.
//

import UIKit
import RxSwift

extension Reactive where Base: TrendCalendarView {
    // MARK: - Binder
    var calendarDataDic: Binder<[DateComponents : Int]> {
        Binder(base) { base, newValue in
            base.reloadDecorations(calendarDataDic: newValue)
        }
    }
}
