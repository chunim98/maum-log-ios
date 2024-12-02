//
//  Int+.swift
//  MaumLog
//
//  Created by 신정욱 on 12/2/24.
//


import UIKit

extension Int {
    var toNegativeName: String {
        switch self {
        case 0:
            return String(localized: "없음")
        case 1:
            return String(localized: "매우약함")
        case 2:
            return String(localized: "약함")
        case 3:
            return String(localized: "보통")
        case 4:
            return String(localized: "심함")
        case 5:
            return String(localized: "매우심함")
        default:
            return "error"
        }
    }
    
    var toOtherName: String {
        switch self {
        case 0:
            return String(localized: "없음")
        case 1:
            return String(localized: "매우약함")
        case 2:
            return String(localized: "약함")
        case 3:
            return String(localized: "보통")
        case 4:
            return String(localized: "강함")
        case 5:
            return String(localized: "매우강함")
        default:
            return "error"
        }
    }

    var toRateColor: UIColor {
        switch self {
        case 0:
            return .chuIvory
        case 1:
            return .init(hex: 0xfdc15a)
        case 2:
            return .init(hex: 0xfdb25e)
        case 3:
            return .init(hex: 0xfda463)
        case 4:
            return .init(hex: 0xfd9669)
        case 5:
            return .init(hex: 0xfd856e)
        default:
            return .clear
        }
    }
    
    var toRateAlpha: CGFloat {
        switch self {
        case 0:
            return 0.5
        case 1:
            return 0.6
        case 2:
            return 0.7
        case 3:
            return 0.8
        case 4:
            return 0.9
        case 5:
            return 1.0
        default:
            return 0
        }
    }
    
    var toUIColor: UIColor {
        UIColor.init(hex: self)
    }
    
    var to16: Int16 {
        Int16(self)
    }
    
    var to32: Int32 {
        Int32(self)
    }
}