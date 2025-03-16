//
//  ConfirmButton.swift
//  MaumLog
//
//  Created by 신정욱 on 3/15/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class ConfirmButton: UIView {
    
    // MARK: Event Enum
    
    enum Event { case negative, other }
    
    // MARK: Components
    
    private let mainHStack = {
        let sv = UIStackView()
        sv.distribution = .fillEqually
        sv.spacing = 15
        return sv
    }()
    
    fileprivate let negativeButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .chuBadRate
        config.baseForegroundColor = .chuWhite
        config.title = "부작용으로 추가"
        
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.isEnabled = false
        return button
    }()
    
    fileprivate let otherButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .chuOtherRate
        config.baseForegroundColor = .chuWhite
        config.title = "기타 증상으로 추가"
        
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.isEnabled = false
        return button
    }()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setAutoLayout() {
        self.addSubview(mainHStack)
        mainHStack.addArrangedSubview(negativeButton)
        mainHStack.addArrangedSubview(otherButton)
        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - Reactive

extension Reactive where Base: ConfirmButton {
    
    var isEnabled: Binder<Bool> {
        Binder(base) {
            $0.negativeButton.isEnabled = $1
            $0.otherButton.isEnabled = $1
        }
    }
    
    var event: Observable<ConfirmButton.Event> {
        Observable.merge(
            base.negativeButton.rx.tap.map { _ in ConfirmButton.Event.negative },
            base.otherButton.rx.tap.map { _ in ConfirmButton.Event.other }
        )
    }
}
