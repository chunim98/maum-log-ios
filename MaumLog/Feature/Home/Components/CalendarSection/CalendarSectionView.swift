//
//  CalendarSectionView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/19/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class CalendarSectionView: UIView {
    
    // MARK: Properties
    
    private let calendarSectionVM = CalendarSectionVM()
    private let bag = DisposeBag()
    
    // MARK: Interface
    
    fileprivate let reloadEvent = PublishSubject<Void>()
    
    // MARK: Components
    
    private let sectionView = SectionView()
    private let headerView = SectionHeaderView("평균 부작용 척도", areButtonsHidden: true)
    private let calendarView = TrendCalendarView()
    
    private let tipLabelContainer = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = .init(edges: 10)
        sv.isLayoutMarginsRelativeArrangement = true
        return sv
    }()
    
    private let tipLabel = {
        let label = UILabel()
        label.text = "* 기타 증상 항목은 계산에 포함되지 않아 \"없음\"으로 표시될 수 있습니다."
        label.font = .boldSystemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setAutoLayout() {
        self.addSubview(sectionView)
        sectionView.headerVStack.addArrangedSubview(headerView)
        sectionView.bodyVStack.addArrangedSubview(calendarView)
        sectionView.footerVStack.addArrangedSubview(tipLabelContainer)
        tipLabelContainer.addArrangedSubview(tipLabel)
        
        sectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: Binding
    
    private func setBinding() {
        let input = CalendarSectionVM.Input(
            reloadEvent: reloadEvent.asObservable()
        )
        let output = calendarSectionVM.transform(input)
        
        // 캘린더 데이터 바인딩
        output.calenderData
            .bind(to: calendarView.rx.calendarDataDic)
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 600)) {
    CalendarSectionView()
}

// MARK: - Reactive

extension Reactive where Base: CalendarSectionView {
    var reloadBinder: Binder<Void> {
        Binder(base) { $0.reloadEvent.onNext($1) }
    }
}
