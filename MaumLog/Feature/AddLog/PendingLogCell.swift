//
//  PendingLogCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/6/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PendingLogCell: UITableViewCell {
    
    static let identifier = "PendingLogCell"
    private let bag = DisposeBag()
    var removeCellTask: (() -> Void)?
    var sliderValueChangedTask: (() -> Void)?
    
    // MARK: - Components
    let mainHStack = {
        let sv = UIStackView()
        sv.spacing = 10
        return sv
    }()
    
    let infoCard = RateCardCell()
    
    let slider = {
        let slider = UISlider()
        slider.maximumValue = 5
        slider.minimumValue = 0
        slider.value = 3
        slider.tintColor = .chuColorPalette[7]
        return slider
    }()
    
    let sliderHStack = {
        let sv = UIStackView()
        sv.spacing = 5
        return sv
    }()
    
    let sliderMinLabel = {
        let label = UILabel()
        label.text = String(localized: "약함")
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    let sliderMaxLabel = {
        let label = UILabel()
        label.text = String(localized: "심함")
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    let removeButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "multiply.circle.fill")?.applyingSymbolConfiguration(.init(pointSize: 15))
        config.baseForegroundColor = .gray
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        button.isHidden = false
        return button
    }()
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setAutoLayout()
        setBinding()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0))
        contentView.backgroundColor = .chuWhite
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(mainHStack)

        mainHStack.addArrangedSubview(infoCard)
        mainHStack.addArrangedSubview(sliderHStack)
        mainHStack.addArrangedSubview(removeButton)

        sliderHStack.addArrangedSubview(sliderMinLabel)
        sliderHStack.addArrangedSubview(slider)
        sliderHStack.addArrangedSubview(sliderMaxLabel)
        
        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 7)) }
        infoCard.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(60)
        }
    }
    
    // MARK: - Binding
    private func setBinding() {
        slider
            .rx.value
            .bind(with: self) { owner, value in
                owner.slider.setValue(floorf(value), animated: false) //툭툭 끊기는 효과 주기
                owner.infoCard.rx.rate.onNext(owner.slider.value)
            }
            .disposed(by: bag)
        
        slider
            .rx.controlEvent([.touchUpInside, .touchUpOutside])
            .bind(with: self) { owner, _ in
                owner.sliderValueChangedTask?()
            }
            .disposed(by: bag)
        
        removeButton
            .rx.tap
            .bind(with: self) { owner, _ in
                owner.removeCellTask?()
            }
            .disposed(by: bag)
    }
    
    func configure(item: SymptomCardData) {
        infoCard.configure(item)
        
        slider.value = Float(item.rate)
        
        if item.isNegative {
            sliderMaxLabel.text = String(localized: "심함")
            slider.tintColor = .chuBadRate // 슬라이더 틴트 색
        } else {
            sliderMaxLabel.text = String(localized: "강함")
            slider.tintColor = .chuOtherRate // 슬라이더 틴트 색
        }
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 75)) {
    PendingLogCell()
}
