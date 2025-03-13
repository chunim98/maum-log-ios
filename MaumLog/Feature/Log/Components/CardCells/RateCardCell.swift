//
//  RateCardCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/3/24.
//

import UIKit

import RxSwift
import SnapKit

final class RateCardCell: UICollectionViewCell {
    
    // MARK: Properties
    
    static let identifier = "RateCardCell"
    var isNegative = false; #warning("상태를 셀이 들고 있는 게 맞음?")
    
    // MARK: Components
    
    private let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 2
        return sv
    }()
    
    private let nameLabelContainer = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = .init(horizontal: 5)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.backgroundColor = .chuTint // temp
        sv.layer.cornerRadius = 7
        sv.clipsToBounds = true
        return sv
    }()
    
    private let nameLabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .chuWhite
        label.text = "여덟글자테스트중" // temp
        return label
    }()
    
    private let rateViewsOutline = {
        let sv  = UIStackView()
        sv.directionalLayoutMargins = .init(edges: 2)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.backgroundColor = .chuTint // temp
        sv.layer.cornerRadius = 7
        sv.clipsToBounds = true
        return sv
    }()
    
    private let rateViewsContainer = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = .init(edges: 1)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.backgroundColor = .chuWhite
        sv.layer.cornerRadius = 5
        sv.clipsToBounds = true
        return sv
    }()
    
    private let rateViewsHStack = {
        let sv = UIStackView()
        sv.distribution = .fillEqually
        sv.layer.cornerRadius = 4
        sv.clipsToBounds = true
        sv.spacing = 1
        return sv
    }()
    
    fileprivate let rateViews = { (0..<5).map { _ in
        let view = UIView()
        view.backgroundColor = .chuWhite // temp
        return view
    } }()
    
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
        mainVStack.addArrangedSubview(nameLabelContainer)
        mainVStack.addArrangedSubview(rateViewsOutline)
        nameLabelContainer.addArrangedSubview(nameLabel)
        rateViewsOutline.addArrangedSubview(rateViewsContainer)
        rateViewsContainer.addArrangedSubview(rateViewsHStack)
        rateViews.forEach { rateViewsHStack.addArrangedSubview($0) }

        mainVStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }
        rateViewsOutline.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(14)
        }
    }
    
    // MARK: Configure
    
    func configure(item: SymptomCardData) {
        nameLabelContainer.backgroundColor = item.hex.toUIColor
        rateViewsOutline.backgroundColor = item.hex.toUIColor
        isNegative = item.isNegative
        nameLabel.text = item.name
        setRate(rate: item.rate)
    }
    
    fileprivate func setRate(rate: Int) {
        guard rate > 0 else { return }
        let color: UIColor = isNegative ? .chuBadRate : .chuOtherRate
        rateViews.forEach { $0.backgroundColor = .chuWhite }
        rateViews[0..<rate].forEach { $0.backgroundColor = color }
    }
}

#Preview(traits: .fixedLayout(width: 100, height: 60)) {
    RateCardCell()
}

// MARK: - Reactive

extension Reactive where Base: RateCardCell {
    var rate: Binder<Float> {
        Binder(base) { $0.setRate(rate: Int($1)) }
    }
}
