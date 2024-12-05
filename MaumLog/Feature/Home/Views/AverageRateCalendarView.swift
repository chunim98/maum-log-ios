//
//  AverageRateCalendarView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/19/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AverageRateCalendarView: UIView {
    private let calendarSubVM = CalendarSubVM()
    private let bag = DisposeBag()
    
    let reloadCalender = PublishSubject<Void>()

    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.backgroundColor = .chuWhite
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 15
        return sv
    }()
    
    let titleHStack = {
        let sv = UIStackView()
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        return sv
    }()
        
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "평균 부작용 척도")
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .chuBlack
        return label
    }()
    
    let calendarView = TrendCalendarView()
    
    let tipLabelContainer = {
        let sv = UIStackView()
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 10, leading: 7.5, bottom: 7.5, trailing: 10)
        return sv
    }()
    
    let tipLabel = {
        let label = UILabel()
        label.text = String(localized: "* 기타 증상 항목은 계산에 포함되지 않아 \"없음\"으로 표시될 수 있습니다.")
        label.font = .boldSystemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        self.addSubview(mainVStack)

        mainVStack.addArrangedSubview(titleHStack)
        mainVStack.addArrangedSubview(DividerView(lineWidth: 1, lineColor: .chuIvory))
        mainVStack.addArrangedSubview(calendarView)
        mainVStack.addArrangedSubview(tipLabelContainer)
        
        titleHStack.addArrangedSubview(titleLabel)
        tipLabelContainer.addArrangedSubview(tipLabel)
        
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: - Binding
    private func setBinding() {
        let input = CalendarSubVM.Input(reloadCalender: reloadCalender.asObservable())
        let output = calendarSubVM.transform(input)
        
        // 캘린더 업데이트
        output.calenderData
            .bind(to: calendarView.rx.calendarDataDic)
            .disposed(by: bag)
    }
}


#Preview(traits: .fixedLayout(width: 400, height: 600)) {
    AverageRateCalendarView()
}
