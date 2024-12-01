//
//  CapsuleCell.swift
//  MaumLog
//
//  Created by 신정욱 on 7/28/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CapsuleCell: UICollectionViewCell, EditButtonCellType {

    static let identifier = "CapsuleCell"
    private let bag = DisposeBag()
    
    var delegate: (any EditButtonCellDelegate)?
    var item: (any EditButtonCellModel)?

    //MARK: - 컴포넌트
    let button = {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("버튼", attributes: .chuBoldTitle(ofSize: 18)) // 임시
        config.titleLineBreakMode = .byTruncatingTail
        config.baseForegroundColor = .chuWhite
        config.baseBackgroundColor = .chuColorPalette[5] // 임시
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        button.clipsToBounds = true
        button.isHidden = false // 임시
        return button
    }()
    
    let editButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "multiply.circle.fill")?.applyingSymbolConfiguration(.init(pointSize: 15))
        config.imagePlacement = .trailing
        config.imagePadding = 5
        config.attributedTitle = AttributedString("버튼", attributes: .chuBoldTitle(ofSize: 18)) // 임시
        config.titleLineBreakMode = .byTruncatingTail
        config.baseForegroundColor = .chuWhite
        config.baseBackgroundColor = .chuColorPalette[5] // 임시
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        button.clipsToBounds = true
        button.isHidden = true // 임시
        return button
    }()
        
    //MARK: - 라이프 사이클
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 오토레이아웃
    private func setAutoLayout() {
        contentView.addSubview(button)
        contentView.addSubview(editButton)
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        editButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - 바인딩
    private func setBinding() {
        editButton
            .rx.tap
            .bind(onNext: { [weak self] in
                guard let self, let item else { return }
                self.delegate?.removeTask(item: item)
            })
            .disposed(by: bag)
    }
    
    
    func setAttributes(item: CapsuleCellModel) {
        self.item = item
        button.configuration?.attributedTitle = AttributedString(item.name, attributes: .chuBoldTitle(ofSize: 18))
        button.configuration?.baseBackgroundColor = item.hex.toUIColor
        button.isHidden = item.isEditMode
        
        editButton.configuration?.attributedTitle = AttributedString(item.name, attributes: .chuBoldTitle(ofSize: 18))
        editButton.configuration?.baseBackgroundColor = item.hex.toUIColor
        editButton.isHidden = !(item.isEditMode)
    }
}

#Preview(traits: .fixedLayout(width: 100, height: 50)) {
    CapsuleCell()
}
