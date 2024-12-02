//
//  NamedRateCardCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/21/24.
//

import UIKit
import SnapKit

final class NamedRateCardCell: UICollectionViewCell {
    
    static let identifier = "NamedRateCardCell"
    var isNegative = false
    
    //MARK: - 컴포넌트
    let overallSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 0
        sv.backgroundColor = .chuColorPalette[6] // 임시
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 0, leading: 5, bottom: 5, trailing: 5)
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
    
    let rateLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "매우심함" // 임시
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .chuColorPalette[6] // 임시
        label.backgroundColor = .chuWhite
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
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
        overallSV.addArrangedSubview(rateLabel)

        rateLabel.setContentHuggingPriority(.init(260), for: .vertical)

        overallSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }

    }
    
    func setAttributes(item: SymptomCardData){
        overallSV.backgroundColor = item.hex.toUIColor
        nameLabel.text = item.name
        isNegative = item.isNegative
        
        setRate(rate: item.rate)
    }
    
    func setRate(rate: Int){
        if isNegative {
            rateLabel.text = rate.toNegativeName
            rateLabel.textColor = .chuBadRate.withAlphaComponent(rate.toRateAlpha)
        }else{
            rateLabel.text = rate.toOtherName
            rateLabel.textColor = overallSV.backgroundColor
        }
        
    }
    
}

#Preview(traits: .fixedLayout(width: 100, height: 60)) {
    NamedRateCardCell()
}
