//
//  CGFloat+.swift
//  MaumLog
//
//  Created by 신정욱 on 12/2/24.
//


import UIKit

extension CGFloat {
    // static이면 저장속성이라도 extension에 구현가능
    static let chuSpace: CGFloat = 15
    static let chuRadius: CGFloat = 15
    static let chuStrokeWidth: CGFloat = 0.5
    static let chuHeight: CGFloat = 50
    var reverse: CGFloat { self * -1 }
}