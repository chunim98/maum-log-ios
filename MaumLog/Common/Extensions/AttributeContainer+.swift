//
//  AttributeContainer+.swift
//  MaumLog
//
//  Created by 신정욱 on 12/2/24.
//


import UIKit

extension AttributeContainer {
    static func chuBoldTitle(ofSize size: CGFloat) -> AttributeContainer {
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: size)
        return container
    }
    
    static func chuTitle(ofSize size: CGFloat) -> AttributeContainer {
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: size)
        return container
    }
}
