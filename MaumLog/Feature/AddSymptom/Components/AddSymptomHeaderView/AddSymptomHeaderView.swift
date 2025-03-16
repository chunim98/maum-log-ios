//
//  AddSymptomHeaderView.swift
//  MaumLog
//
//  Created by 신정욱 on 3/16/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class AddSymptomHeaderView: UIView {

    // MARK: Components
    
    private let titleLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .chuBlack
        label.text = "새 증상 등록"
        return label
    }()
    
    fileprivate let closeButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "x")?
            .withRenderingMode(.alwaysTemplate)
            .resizeImage(newWidth: 18)
            .withTintColor(.chuBlack)
        return UIButton(configuration: config)
    }()

    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .chuIvory
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setAutoLayout() {
        self.addSubview(titleLabel)
        self.addSubview(closeButton)
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        closeButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }
}

// MARK: - Reactive

extension Reactive where Base: AddSymptomHeaderView {
    var closeButtonEvent: Observable<AddSymptomEvent> {
        base.closeButton.rx.tap.map { _ in AddSymptomEvent.dismiss }
    }
}
