//
//  DividerView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/23/24.
//

import UIKit
import SnapKit

final class DividerView: UIView {
    
    let lineWidth: CGFloat

    let line = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    
    init(lineWidth: CGFloat, lineColor: UIColor) {
        self.lineWidth = lineWidth
        self.line.backgroundColor = lineColor
        
        super.init(frame: .zero)
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setAutoLayout() {
        self.addSubview(line)
        
        line.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(lineWidth)
        }
    }
    
}



#Preview(traits: .fixedLayout(width: 100, height: 100)) {
    DividerView(lineWidth: 5, lineColor: .chuBlack)
}
