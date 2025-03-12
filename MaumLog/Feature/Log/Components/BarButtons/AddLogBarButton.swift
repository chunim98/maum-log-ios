//
//  AddLogBarButton.swift
//  MaumLog
//
//  Created by 신정욱 on 3/12/25.
//

import UIKit

import RxSwift

final class AddLogBarButton: UIBarButtonItem {

    // MARK: Life Cycle
    
    override init() {
        super.init()
        
        // 속성 초기화
        self.image = UIImage(named: "plus")?.resizeImage(newWidth: 18)
        self.tintColor = .chuBlack
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Reactive

extension Reactive where Base: AddLogBarButton {
    var event: Observable<LogVCButtonEvent> { base.rx.tap.map { _ in .pushAddLog } }
}
