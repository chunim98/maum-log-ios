//
//  UIColor+.swift
//  MaumLog
//
//  Created by 신정욱 on 12/2/24.
//


import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xff) >> 0) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    static var chuWhite: UIColor {
        UIColor.init(hex: 0xfbf9f7)
    }
    
    static var chuIvory: UIColor {
        UIColor.init(hex: 0xefebeb)
    }
    
    static var chuBlack: UIColor {
        UIColor.init(hex: 0x464044)
    }
    
    static var chuLightGray: UIColor {
        UIColor.init(hex: 0xd6d4d2)
    }
    
    static var chuBadRate: UIColor {
        UIColor.init(hex: 0xd49773)
    }
    
    static var chuOtherRate: UIColor {
        UIColor.chuColorPalette[2]
    }
    
    static var chuColorPalette: [UIColor] {
        let array: [UIColor] = [
            .init(hex: 0xd4b8a6),
            .init(hex: 0x8e7d7b),
            .init(hex: 0x7b6d71),
            .init(hex: 0xa28d8d),
            .init(hex: 0x7f6f7b),
            .init(hex: 0x6b5a6b),
            .init(hex: 0x9d7a73),
            .init(hex: 0xb4a79b),
            .init(hex: 0x6b6f43),
            .init(hex: 0x8a8c5e),
            .init(hex: 0x9a9e71),
            .init(hex: 0xb4b86e)
        ]
        return array
    }
    
    static let chuTint = UIColor.chuColorPalette.randomElement()!
    
    var toHexInt: Int {
        // CGColor를 sRGB로 변환
        guard let cgColorInRGB = cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil),
              let components = cgColorInRGB.components else {
            return 0x0 // 변환 실패 시 기본값
        }
        // RGB 구성 요소 추출
        let r = components[0]
        let g = components[1]
        let b = (components.count > 2 ? components[2] : g) // 회색조일 경우 g 사용
        let a = cgColor.alpha
        // RGB 값을 8비트 정수로 변환
        let red = Int(r * 255)
        let green = Int(g * 255)
        let blue = Int(b * 255)
        // 16진수 Int로 결합
        var hexInt = (red << 16) | (green << 8) | blue
        // 알파 값이 1이 아닐 경우 알파 포함
        if a < 1 {
            let alpha = Int(a * 255)
            hexInt = (hexInt << 8) | alpha
        }
        // 결과 반환
        return hexInt
    }
}
