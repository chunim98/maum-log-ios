//
//  Array+Int.swift
//  MaumLog
//
//  Created by 신정욱 on 12/2/24.
//


import UIKit

extension Array where Element == Int {
    var to16Arr: [Int16] {
        self.map{ Int16($0) }
    }
    var to32Arr: [Int32] {
        self.map{ Int32($0) }
    }
}