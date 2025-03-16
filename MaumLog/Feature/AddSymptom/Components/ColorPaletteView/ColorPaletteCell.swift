//
//  ColorPaletteCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/9/24.
//

import UIKit

import SnapKit

final class ColorPaletteCell: UICollectionViewCell {
    
    // MARK: Properties
    
    static let identifier = "ColorPaletteCell"
    
    // MARK: Components
    
    private let circleView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
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
        contentView.addSubview(circleView)
        circleView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: Configure
    
    func configure(_ hex: Int) { circleView.backgroundColor = hex.toUIColor }
}

#Preview(traits: .fixedLayout(width: 100, height: 100)) {
    ColorPaletteCell()
}
