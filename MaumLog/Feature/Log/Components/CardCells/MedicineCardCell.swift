//
//  MedicineCardCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import SnapKit

final class MedicineCardCell: UICollectionViewCell {
    
    static let identifier = "MedicineCardCell"
    var isNegative = false
    
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.backgroundColor = .chuBlack
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 10
        return sv
    }()
    
    let nameLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "여덟글용" // 임시
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .chuWhite
         return label
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout(){
        contentView.addSubview(mainVStack)
        mainVStack.addArrangedSubview(nameLabel)
        
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(2) }
    }
    
    func configure(item: MedicineCardData){
        nameLabel.text = item.name
    }
}

#Preview(traits: .fixedLayout(width: 150, height: 30)) {
    MedicineCardCell()
}

