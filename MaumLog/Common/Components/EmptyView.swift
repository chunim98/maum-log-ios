//
//  EmptyView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/27/24.
//

import UIKit
import SnapKit

final class EmptyView: UIView {
    
    //MARK: - 컴포넌트
    let stackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        return sv
    }()
    
    let image = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    let label = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    //MARK: - 라이프사이클
    // 이미지까지 필요할 때
    init(text: String, textSize: CGFloat, image: UIImage?, imageSize: CGFloat? = nil, spacing: CGFloat) {
        self.label.text = text
        self.label.font = .systemFont(ofSize: textSize)
        self.image.image = image
        self.stackView.spacing = spacing
        
        if let imageSize {
            self.image.image = self.image.image?.resizeImage(newWidth: imageSize)
        }
        
        super.init(frame: .zero)
        setAutoLayout()
    }
    
    // 텍스트만 필요할 때
    convenience init(text: String, textSize: CGFloat) {
        self.init(text: text, textSize: textSize, image: nil, imageSize: nil, spacing: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 오토레이아웃
    private func setAutoLayout() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(label)
        
        stackView.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
}

#Preview {
    EmptyView(text: "이거 아무것도 아님ㅇㅇ", textSize: 18)
}
