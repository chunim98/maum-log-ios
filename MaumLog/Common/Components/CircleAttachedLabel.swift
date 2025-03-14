//
//  CircleAttachedLabel.swift
//  MaumLog
//
//  Created by 신정욱 on 3/10/25.
//

import UIKit

final class CircleAttachedLabel: UILabel {
    
    let text_: String
    let circleColor: UIColor
    
    // MARK: Life Cycle
    
    init(_ text: String, _ circleColor: UIColor) {
        self.text_ = text + " "
        self.circleColor = circleColor
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configure
    
    private func configure() {
        // 볼드체 설정
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.chuBlack,
        ]
        
        // 텍스트 뒤에 이미지 붙이기
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "circle.fill")?
            .resizeImage(newWidth: 12)
            .withTintColor(circleColor)
        
        // 텍스트 설정
        let attributedString = NSMutableAttributedString(string: text_, attributes: attributes)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        
        self.attributedText = attributedString
    }
}
