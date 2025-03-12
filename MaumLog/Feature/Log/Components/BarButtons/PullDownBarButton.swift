//
//  PullDownBarButton.swift
//  MaumLog
//
//  Created by 신정욱 on 3/12/25.
//


import UIKit

import RxSwift

final class PullDownBarButton: UIBarButtonItem {
    
    // MARK: Properties
    
    fileprivate var ascendingOrder: UIAction!
    fileprivate var descendingOrder: UIAction!
    
    // MARK: Interface
    
    fileprivate let event = PublishSubject<LogVCButtonEvent>()
    
    // MARK: Life Cycle
    
    override init() {
        super.init()
        
        // 속성 초기화
        self.image = UIImage(systemName: "ellipsis")?
            .applyingSymbolConfiguration(.init(pointSize: 18))
        self.tintColor = .chuBlack
        setMenu()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Menu
    
    private func setMenu() {
        let edit = UIAction(
            title: "편집",
            image: UIImage(systemName: "square.and.pencil")
        ) { [weak self] _ in
            self?.event.onNext(.edit)
        }
        
        ascendingOrder = UIAction(title: "최신 항목 순으로") { [weak self] _ in
            self?.event.onNext(.sortByAscending)
        }
        
        descendingOrder = UIAction(title: "오래된 항목 순으로") { [weak self] _ in
            self?.event.onNext(.sortByDescending)
        }
        
        // 팝업버튼 설정
        let sortByMenu = UIMenu(
            title: "다음으로 정렬",
            image: UIImage(systemName: "arrow.up.arrow.down"),
            options: .singleSelection,
            children: [ascendingOrder, descendingOrder]
        )
        
        self.menu = UIMenu(title: "옵션", children: [edit, sortByMenu])
    }
}

// MARK: - Reactive

extension Reactive where Base: PullDownBarButton {
    
    var sortState: Binder<Bool> {
        Binder(base) { ($1 ? $0.descendingOrder : $0.ascendingOrder)?.state = .on }
    }
    
    var event: Observable<LogVCButtonEvent> { base.event.asObservable() }
}
