//
//  DateFormatter+.swift
//  MaumLog
//
//  Created by 신정욱 on 12/2/24.
//


import UIKit

extension DateFormatter {
    static var forSort: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    static var forHeader: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        return formatter
    }
}