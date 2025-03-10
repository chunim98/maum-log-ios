//
//  SectionView.swift
//  MaumLog
//
//  Created by 신정욱 on 3/10/25.
//

import UIKit

import SnapKit

final class SectionView: UIView {

    // MARK: Components
    
    private let mainVStack = {
        let sv = UIStackView()
        sv.layer.cornerRadius = 15
        sv.clipsToBounds = true
        sv.axis = .vertical
        sv.spacing = 1
        return sv
    }()
    
    let headerVStack = {
        let sv = UIStackView()
        sv.backgroundColor = .chuWhite
        return sv
    }()
    
    let bodyVStack = {
        let sv = UIStackView()
        sv.backgroundColor = .chuWhite
        sv.axis = .vertical
        return sv
    }()
    
    let footerVStack = {
        let sv = UIStackView()
        sv.backgroundColor = .chuWhite
        sv.axis = .vertical
        return sv
    }()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setAutoLayout() {
        self.addSubview(mainVStack)
        mainVStack.addArrangedSubview(headerVStack)
        mainVStack.addArrangedSubview(bodyVStack)
        mainVStack.addArrangedSubview(footerVStack)
        
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

#Preview {
    SectionView()
}
