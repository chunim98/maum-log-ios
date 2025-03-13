//
//  MedicineCardCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit

import SnapKit

final class MedicineCardCell: UICollectionViewCell {
    
    // MARK: Properties
    
    static let identifier = "MedicineCardCell"
    
    // MARK: Components
    
    private let mainVStack = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = .init(edges: 5)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.backgroundColor = .chuBlack
        sv.layer.cornerRadius = 10
        sv.clipsToBounds = true
        sv.axis = .vertical
        return sv
    }()
    
    private let nameLabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .chuWhite
        label.text = "여덟글용" // temp
        return label
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
        contentView.addSubview(mainVStack)
        mainVStack.addArrangedSubview(nameLabel)
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(2) }
    }
    
    // MARK: Configure
    
    func configure(_ data: MedicineCardData) { nameLabel.text = data.name }
}

#Preview(traits: .fixedLayout(width: 150, height: 30)) {
    MedicineCardCell()
}

