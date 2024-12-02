//
//  OutlinedView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/21/24.
//

import UIKit
import SnapKit

final class OutlinedView: UIView {
    
    let strokeWidth: CGFloat
    let isflipped: Bool
    
    let outer = {
        let view = UIView()
        view.backgroundColor = .chuLightGray
        view.clipsToBounds = true
        return view
    }()
    
    let inner = {
        let view = UIView()
        view.backgroundColor = .chuWhite
        view.clipsToBounds = true
        return view
    }()
    

    
    init(strokeWidth: CGFloat, isflipped: Bool = false) {
        self.strokeWidth = strokeWidth
        self.isflipped = isflipped
        outer.layer.cornerRadius = .chuRadius + strokeWidth
        inner.layer.cornerRadius = .chuRadius
        
        if isflipped {
            outer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            inner.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }else{
            outer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            inner.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        super.init(frame: .zero) // 뷰컨에서 프레임 다시 잡음 ㄱㅊㄱㅊ
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAutoLayout() {
        self.addSubview(outer)
        self.addSubview(inner)
        
        outer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: (strokeWidth * -1), bottom: 0, right: (strokeWidth * -1))) // 상단바, 하단바로써의 사용을 상정
        }
        
        if isflipped {
            inner.snp.makeConstraints { make in
                make.edges.equalTo(outer).inset(UIEdgeInsets(top: 0, left: strokeWidth, bottom: strokeWidth, right: strokeWidth))
            }
        }else{
            inner.snp.makeConstraints { make in
                make.edges.equalTo(outer).inset(UIEdgeInsets(top: strokeWidth, left: strokeWidth, bottom: 0, right: strokeWidth))
            }
        }
    }
    
}

#Preview(traits: .fixedLayout(width: 100, height: 100)) {
    OutlinedView(strokeWidth: 3, isflipped: false)
}
