//
//  ColorPaletteCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/9/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ColorPaletteCell: UICollectionViewCell {
    
    static let identifier = "ColorPaletteCell"
    private let bag = DisposeBag()
    var colorButtonTask: (() -> Void)?
    
    // MARK: - Components
    let colorButton = UIButton()

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
        contentView.addSubview(colorButton)
        colorButton.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: - Binding
    private func setBinding() {
        colorButton
            .rx.tap
            .bind(onNext: { [weak self] in
                self?.colorButtonTask?()
                HapticManager.shared.occurSelect()
            })
            .disposed(by: bag)
    }
    
    func configure(hex: Int) {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = hex.toUIColor
        config.cornerStyle = .capsule
        colorButton.configuration = config
    }
}

#Preview(traits: .fixedLayout(width: 100, height: 100)) {
    ColorPaletteCell()
}
