//
//  AddMedicineHeaderView.swift
//  MaumLog
//
//  Created by 신정욱 on 4/14/25.
//

import UIKit
import Combine

import SnapKit

final class AddMedicineHeaderView: UIView {

    // MARK: Components
    
    private let titleLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .chuBlack
        label.text = "복용 중인 약 등록"
        return label
    }()
    
    private let closeButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "x")?
            .withRenderingMode(.alwaysTemplate)
            .resizeImage(newWidth: 18)
            .withTintColor(.chuBlack)
        return UIButton(configuration: config)
    }()

    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .chuIvory
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setAutoLayout() {
        self.addSubview(titleLabel)
        self.addSubview(closeButton)
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        closeButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }
}

// MARK: - Public Publisher

extension AddMedicineHeaderView {
    var closeButtonEventPublisher: AnyPublisher<AddMedicineEvent, Never> {
        closeButton.publisher(for: .touchUpInside)
            .map { _ in .dismiss }
            .eraseToAnyPublisher()
    }
}
