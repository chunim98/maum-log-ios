//
//  EditButtonCellModel.swift
//  MaumLog
//
//  Created by 신정욱 on 12/7/24.
//


import UIKit
import Differentiator

// 편집가능한 셀에 쓰이는 모델은 아래 프로토콜을 따라야 함
protocol EditButtonCellModel {
    var isEditMode: Bool { get set }
}
