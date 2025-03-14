//
//  CircleButton.swift
//  MaumLog
//
//  Created by 신정욱 on 3/12/25.
//

import UIKit

final class CircleButton: UIButton {
    
    // MARK: Properties
    
    private let image: UIImage?
    
    // MARK: Life Cycle
    
    init(_ image: UIImage?) {
        self.image = image?.withRenderingMode(.alwaysTemplate)
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configure
    
    private func configure() {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .chuWhite
        config.baseBackgroundColor = .chuTint
        config.cornerStyle = .capsule
        config.image = image
        
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.75
        self.layer.shadowRadius = 5
        self.configuration = config
    }
}
