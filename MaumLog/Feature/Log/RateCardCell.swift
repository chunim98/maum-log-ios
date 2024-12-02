//
//  RateCardCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/3/24.
//

import UIKit
import SnapKit

final class RateCardCell: UICollectionViewCell {
    
    static let identifier = "RateCardCell"
    var isNegative = false
    
    //MARK: - 컴포넌트
    let overallSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 2
        return sv
    }()
    
    let nameLabelBackground = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 0, leading: 5, bottom: 0, trailing: 5)
        sv.backgroundColor = .chuColorPalette[6] // 임시
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 7
        return sv
    }()
    
    let nameLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "여덟글자테스트중"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .chuWhite
        return label
    }()
    
    let rateViewsOutline = {
        let sv  = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
        sv.backgroundColor = .chuColorPalette[6] // 임시
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 7
        return sv
    }()
    
    let rateViewsBackground = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 1, leading: 1, bottom: 1, trailing: 1)
        sv.backgroundColor = .chuWhite
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 5
        return sv
    }()
    
    let rateViewsSV = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 1
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 4
        return sv
    }()
    
    let rateViews = {
        var views = [UIView]()
        for i in 0..<5 {
            views.append(.init())
        }
        views.forEach {
            $0.backgroundColor = .chuWhite // 임시

        }
        return views
    }()
    
    // MARK: - 라이프 사이클
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        nameLabel.layer.cornerRadius = nameLabel.bounds.height / 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 오토레이아웃
    private func setAutoLayout(){
        contentView.addSubview(overallSV)
        overallSV.addArrangedSubview(nameLabelBackground)
        nameLabelBackground.addArrangedSubview(nameLabel)
        overallSV.addArrangedSubview(rateViewsOutline)
        rateViewsOutline.addArrangedSubview(rateViewsBackground)
        rateViewsBackground.addArrangedSubview(rateViewsSV)
        rateViews.forEach { rateViewsSV.addArrangedSubview($0) } // 뷰 5개 모두 저장

        overallSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
        rateViewsOutline.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    func setAttributes(item: SymptomCardData){
        nameLabelBackground.backgroundColor = item.hex.toUIColor
        rateViewsOutline.backgroundColor = item.hex.toUIColor
        nameLabel.text = item.name
        isNegative = item.isNegative
        
        setRate(rate: item.rate)
    }
    
    func setRate(rate: Int){
        rateViews.forEach { $0.backgroundColor = .chuWhite } // 다시 호출되었을 때 초기화 하고 다시 그리기
        guard rate > 0 else { return }
        
        if isNegative {
            for i in 1...rate {
                rateViews[i - 1].backgroundColor = .chuBadRate
            }
        }else{
            for i in 1...rate {
                rateViews[i - 1].backgroundColor = .chuOtherRate
            }
        }
    }
    
}

#Preview(traits: .fixedLayout(width: 100, height: 60)) {
    RateCardCell()
}
