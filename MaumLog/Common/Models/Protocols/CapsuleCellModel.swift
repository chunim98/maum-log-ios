//
//  CapsuleCellModel.swift
//  MaumLog
//
//  Created by 신정욱 on 12/7/24.
//


import UIKit
import Differentiator

// 캡슐 셀에 쓰이는 모델은 아래 프로토콜을 따라야 함
protocol CapsuleCellModel: EditButtonCellModel {
    var name: String { get }
    var hex: Int { get }
}

// 캡슐 셀에 쓰이는 모델에 색상 데이터가 없을 때 기본색상 제공
extension CapsuleCellModel {
    var hex: Int { UIColor.chuBlack.toHexInt }
}
