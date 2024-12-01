//
//  LogData.swift
//  MaumLog
//
//  Created by 신정욱 on 8/27/24.
//

import Foundation
import Differentiator

struct LogData: EditButtonCellModel {
    var date: Date = Date()
    let symptomCards: [SymptomCardData]
    let medicineCards: [MedicineCardData]
    var isEditMode: Bool = false // 코어데이터에 저장안되는 변수
}

extension LogData: Equatable, IdentifiableType {
    // 이게 달라지면 rx데이터소스에서 insert처리
    var identity: Date {
        self.date
    }
    // 이게 false면 rx데이터소스에서 reload처리
    static func == (lhs: LogData, rhs: LogData) -> Bool {
        lhs.date == rhs.date && lhs.isEditMode == rhs.isEditMode
    }
}
