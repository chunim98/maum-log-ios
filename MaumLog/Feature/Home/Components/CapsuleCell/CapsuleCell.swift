//
//  CapsuleCell.swift
//  MaumLog
//
//  Created by 신정욱 on 7/28/24.
//

import UIKit

import SnapKit

final class CapsuleCell: UICollectionViewCell {
    
    // MARK: Properties
    
    static let identifier = "CapsuleCell"
    
    // MARK: Components
    
    private let mainHStack = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = .init(horizontal: 15)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.backgroundColor = .chuBadRate // temp
        sv.layer.cornerRadius = 15
        sv.clipsToBounds = true
        return sv
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textAlignment = .center
        label.textColor = .chuWhite
        label.text = "증상명" // temp
        return label
    }()
    
    private let imageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "multiply.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.chuWhite)
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true // temp
        return iv
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
        contentView.addSubview(mainHStack)
        mainHStack.addArrangedSubview(titleLabel)
        mainHStack.addArrangedSubview(imageView)

        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        imageView.snp.makeConstraints { $0.size.equalTo(15) }
    }
    
    // MARK: Configure
    
    func configure(_ data: CapsuleCellModel) {
        mainHStack.backgroundColor = data.hex.toUIColor
        imageView.isHidden = !data.isEditMode
        titleLabel.text = data.name
    }
}

#Preview(traits: .fixedLayout(width: 100, height: 50)) {
    CapsuleCell()
}
