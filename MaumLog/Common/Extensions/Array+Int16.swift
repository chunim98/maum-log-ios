//
//  Array+Int16.swift
//  MaumLog
//
//  Created by 신정욱 on 12/2/24.
//


import UIKit

extension Array where Element == Int16 {
    var toIntArr: [Int] {
        self.map{ Int($0) }
    }
}