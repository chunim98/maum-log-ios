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
    
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()
    
    let titleAndActionHStack = {
        let sv = UIStackView()
        sv.spacing = 10
        sv.alignment = .center
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
    
    // MARK: - Life Cycle
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
    
    // MARK: - Layout
    func setAutoLayout() {
        contentView.addSubview(mainVStack)
        mainVStack.addArrangedSubview(titleAndActionHStack)
        titleAndActionHStack.addArrangedSubview(titleLabel)
        titleAndActionHStack.addArrangedSubview(toggle)
        mainVStack.addArrangedSubview(captionLabel)
        
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(10) }
    }
    
    // MARK: - Binding
    func setBinding() {
        toggle
            .rx.controlEvent(.valueChanged)
            .withLatestFrom(toggle.rx.value)
            .bind(with: self, onNext: { owner, bool in
                owner.toggleTask?(bool)
            })
            .disposed(by: bag)
    }
    
    func configure(title: String, caption: String, isOn: Bool) {
        titleLabel.text = title
        captionLabel.text = caption
        toggle.isOn = isOn
    }

}

#Preview(traits: .fixedLayout(width: 400, height: 100)) {
    ToggleTypeCell()
}
