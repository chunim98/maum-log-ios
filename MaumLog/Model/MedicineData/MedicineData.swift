//
//  MedicineData.swift
//  MaumLog
//
//  Created by 신정욱 on 8/27/24.
//

import Foundation
import Differentiator

struct MedicineData: CapsuleCellModel {
    var createDate: Date = Date()
    let name: String
    var isEditMode: Bool = false // 코어데이터에 저장안되는 변수
}

extension MedicineData: Equatable, IdentifiableType {
    // 이게 달라지면 rx데이터소스에서 insert처리
    var identity: Date {
        self.createDate
    }
    // 이게 false면 rx데이터소스에서 reload처리
    static func == (lhs: MedicineData, rhs: MedicineData) -> Bool {
        lhs.createDate == rhs.createDate && lhs.isEditMode == rhs.isEditMode
    }
}
