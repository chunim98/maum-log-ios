//
//  ButtonTypeCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/10/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ButtonTypeCell: UITableViewCell {
    
    static let identifier = "ButtonTypeCell"
    private let bag = DisposeBag()
    var buttonTask: (() -> Void)?
    
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
        config.baseForegroundColor = .chuWhite
        config.title = "버튼"
        config.titleAlignment = .center
        config.cornerStyle = .capsule
        return UIButton(configuration: config)
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
        horizontalSV.addArrangedSubview(button)
        verticalSV.addArrangedSubview(captionLabel)
        
        button.setContentHuggingPriority(.init(900), for: .horizontal)
        
        verticalSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }

    }
    
    //MARK: - 바인딩
    func setBinding() {
        button
            .rx.tap
            .bind(onNext: { [weak self] in
                self?.buttonTask?()
            })
            .disposed(by: bag)
    }
    
    func setAttributes(title: String, caption: String, buttonTitle: String, buttonColor: UIColor) {
        titleLabel.text = title
        captionLabel.text = caption
        
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .chuWhite
        config.baseBackgroundColor = buttonColor
        config.title = buttonTitle
        config.titleAlignment = .center
        config.cornerStyle = .capsule
        button.configuration = config
    }

}

#Preview(traits: .fixedLayout(width: 400, height: 100)) {
    ButtonTypeCell()
}
