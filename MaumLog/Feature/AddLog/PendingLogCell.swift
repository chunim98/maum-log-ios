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
    
    //MARK: - 메모리 올리기
    let overallSV = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fill
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
    
    let sliderSV = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 5
        sv.distribution = .fill
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
    
    //MARK: - 라이프 사이클
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
    
    //MARK: - 오토레이아웃
    private func setAutoLayout() {
        contentView.addSubview(overallSV)

        overallSV.addArrangedSubview(infoCard)
        overallSV.addArrangedSubview(sliderSV)
        overallSV.addArrangedSubview(removeButton)

        sliderSV.addArrangedSubview(sliderMinLabel)
        sliderSV.addArrangedSubview(slider)
        sliderSV.addArrangedSubview(sliderMaxLabel)
        
        overallSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 7))
        }
        infoCard.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(60)
        }
    }
    
    //MARK: - 바인딩
    private func setBinding() {
        slider
            .rx.value
            .bind(onNext: { [weak self] value in
                guard let self else { return }
                
                slider.setValue(floorf(value), animated: false) //툭툭 끊기는 효과 주기
                infoCard.setRate(rate: Int(slider.value)) //소수점 절사
            })
            .disposed(by: bag)
        
        
        slider
            .rx.controlEvent([.touchUpInside, .touchUpOutside])
            .bind(onNext: { [weak self] value in
                self?.sliderValueChangedTask?()
            })
            .disposed(by: bag)
        
        
        removeButton
            .rx.tap
            .bind(onNext: { [weak self] in
                self?.removeCellTask?()
            })
            .disposed(by: bag)
    }

    
    func setAtrributes(item: SymptomCardData) {
        infoCard.setAttributes(item: item)

        
        slider.value = Float(item.rate)
        
        if item.isNegative {
            sliderMaxLabel.text = String(localized: "심함")
            slider.tintColor = .chuBadRate // 슬라이더 틴트 색
        }else{
            sliderMaxLabel.text = String(localized: "강함")
            slider.tintColor = .chuOtherRate // 슬라이더 틴트 색
        }
    }
    
}

#Preview(traits: .fixedLayout(width: 400, height: 75)) {
    PendingLogCell()
}
