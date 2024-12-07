//
//  LoggableCapsuleCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/5/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoggableCapsuleCell: UICollectionViewCell {
    static let identifier = "LoggableCapsuleCell"
    private let bag = DisposeBag()
    var addTask: (() -> Void)?
    
    // MARK: - Components
    let button = {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("버튼", attributes: .chuBoldTitle(ofSize: 18)) // 임시
        config.titleLineBreakMode = .byTruncatingTail
        config.baseForegroundColor = .chuWhite
        config.baseBackgroundColor = .chuColorPalette[5] // 임시
        
        let button = UIButton(configuration: config)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        return button
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
        contentView.addSubview(button)
        button.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - Binding
    private func setBinding() {
        button
            .rx.tap
            .bind(onNext: { [weak self] in
                self?.addTask?()
                HapticManager.shared.occurSelect()
            })
            .disposed(by: bag)
    }
    
    func configure(item: SymptomData) {
        button.configuration?.attributedTitle = AttributedString(item.name, attributes: .chuBoldTitle(ofSize: 18))
        button.configuration?.baseBackgroundColor = item.hex.toUIColor
    }
}

#Preview(traits: .fixedLayout(width: 100, height: 50)) {
    LoggableCapsuleCell()
}
