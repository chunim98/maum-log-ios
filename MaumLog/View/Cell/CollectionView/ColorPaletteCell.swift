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
    
    // MARK: - 컴포넌트
    let colorButton = UIButton()

    // MARK: - 라이프 사이클
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
        setBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 오토레이아웃
    private func setAutoLayout() {
        contentView.addSubview(colorButton)
        
        colorButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - 바인딩
    private func setBinding() {
        colorButton
            .rx.tap
            .bind(onNext: { [weak self] in
                self?.colorButtonTask?()
                HapticManager.shared.occurSelect()
            })
            .disposed(by: bag)
    }
    
    func setColorButton(hex: Int) {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = hex.toUIColor
        config.cornerStyle = .capsule
        colorButton.configuration = config
    }
}

#Preview(traits: .fixedLayout(width: 100, height: 100)) {
    ColorPaletteCell()
}
