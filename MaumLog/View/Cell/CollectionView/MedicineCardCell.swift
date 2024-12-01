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
    
    //MARK: - 컴포넌트
    let overallSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 0
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
    
    // MARK: - 라이프 사이클
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 오토레이아웃
    private func setAutoLayout(){
        contentView.addSubview(overallSV)
        overallSV.addArrangedSubview(nameLabel)
        
        overallSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
    }
    
    func setAttributes(item: MedicineCardData){
        nameLabel.text = item.name
    }
    
}

#Preview(traits: .fixedLayout(width: 150, height: 30)) {
    MedicineCardCell()
}

