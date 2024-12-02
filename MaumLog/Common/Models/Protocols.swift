//
//  Protocols.swift
//  MaumLog
//
//  Created by 신정욱 on 8/28/24.
//

import UIKit
import Differentiator

// 편집가능한 셀은 아래 프로토콜을 따라야 함
protocol EditButtonCellType {
    static var identifier: String { get }
    var delegate: EditButtonCellDelegate? { get set }
    var item: EditButtonCellModel? { get set }
}

// 편집가능한 셀을 가지는 객체는 아래 프로토콜을 따라야 함
protocol EditButtonCellDelegate {
    func removeTask(item: EditButtonCellModel) -> Void
}

// 편집가능한 셀에 쓰이는 모델은 아래 프로토콜을 따라야 함
protocol EditButtonCellModel {
    var isEditMode: Bool { get set }
}

// 캡슐 셀에 쓰이는 모델은 아래 프로토콜을 따라야 함
protocol CapsuleCellModel: EditButtonCellModel {
    var name: String { get }
    var hex: Int { get }
}
// 캡슐 셀에 쓰이는 모델에 색상 데이터가 없을 때 기본색상 제공
extension CapsuleCellModel {
    var hex: Int { UIColor.chuBlack.toHexInt }
}




