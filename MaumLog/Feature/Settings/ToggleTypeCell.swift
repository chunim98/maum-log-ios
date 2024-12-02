//
//  ToggleTypeCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/11/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ToggleTypeCell: UITableViewCell {

    static let identifier = "ToggleTypeCell"
    private let bag = DisposeBag()
    var toggleTask: ((Bool) -> Void)?
    
    //MARK: - 컴포넌트
    let horizontalSV = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = 10
        sv.alignment = .center
        return sv
    }()
    
    let verticalSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 10
        return sv
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = "설정에 관한 내용"
        return label
    }()
    
    let captionLabel = {
        let label = UILabel()
        label.text = "설정에 관한 설명은 여기 달림"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = .max
        return label
    }()
    
    let button = {
        var config = UIButton.Configuration.tinted()
        config.baseForegroundColor = .black
        config.title = "버튼"
        config.titleAlignment = .center
        return UIButton(configuration: config)
    }()
    
    let toggle = {
        let toggle = UISwitch()
        toggle.onTintColor = .chuTint
        return toggle
    }()
    

    //MARK: - 라이프 사이클
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = .chuWhite
        
        setAutoLayout()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 오토레이아웃
    func setAutoLayout() {
        contentView.addSubview(verticalSV)
        verticalSV.addArrangedSubview(horizontalSV)
        horizontalSV.addArrangedSubview(titleLabel)
        horizontalSV.addArrangedSubview(toggle)
        verticalSV.addArrangedSubview(captionLabel)
        
        verticalSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    //MARK: - 바인딩
    func setBinding() {
        toggle
            .rx.controlEvent(.valueChanged)
            .withLatestFrom(toggle.rx.value)
            .bind(onNext : { [weak self] bool in
                self?.toggleTask?(bool)
            })
            .disposed(by: bag)
    }
    
    func setAttributes(title: String, caption: String, isOn: Bool) {
        titleLabel.text = title
        captionLabel.text = caption
        toggle.isOn = isOn
    }

}

#Preview(traits: .fixedLayout(width: 400, height: 100)) {
    ToggleTypeCell()
}
