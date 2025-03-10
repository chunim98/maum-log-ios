//
//  SymptomSectionHeaderView.swift
//  MaumLog
//
//  Created by 신정욱 on 3/10/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class SymptomSectionHeaderView: UIView {

    // MARK: Components
    
    private let headerHStack = {
        let sv = UIStackView()
        sv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sv.directionalLayoutMargins = .init(top: 5, leading: 10, bottom: 5)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.spacing = 10
        return sv
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.text = "등록된 증상"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .chuBlack
        return label
    }()
    
    fileprivate let editButton = {
        var config = UIButton.Configuration.filled()
        config.title = "편집" // temp
        config.baseForegroundColor = .chuBlack // temp
        config.baseBackgroundColor = .clear // temp
        config.cornerStyle = .capsule
        return UIButton(configuration: config)
    }()
    
    fileprivate let addButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "plus")?
            .resizeImage(newWidth: 18)
            .withRenderingMode(.alwaysTemplate)
        config.baseForegroundColor = .chuBlack
        return UIButton(configuration: config)
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
        self.addSubview(headerHStack)
        headerHStack.addArrangedSubview(titleLabel)
        headerHStack.addArrangedSubview(UIView())
        headerHStack.addArrangedSubview(editButton)
        headerHStack.addArrangedSubview(addButton)
        
        headerHStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - Reactive

extension Reactive where Base: SymptomSectionHeaderView {
    
    var editButtonState: Binder<Bool> {
        Binder(base) {
            $0.editButton.configuration?.title = $1 ? "완료" : "편집"
            $0.editButton.configuration?.baseForegroundColor = $1 ? .chuWhite : .chuBlack
            $0.editButton.configuration?.baseBackgroundColor = $1 ? .chuTint : .clear
        }
    }

    var editButtonTapEvent: Observable<Void> {
        base.editButton.rx.tap.asObservable()
    }
    
    var addButtonTapEvent: Observable<Void> {
        base.addButton.rx.tap.asObservable()
    }
}

