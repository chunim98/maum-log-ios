//
//  SymptomData.swift
//  MaumLog
//
//  Created by 신정욱 on 8/27/24.
//

import Foundation
import Differentiator

struct SymptomData: CapsuleCellModel {
    let name: String
    let hex: Int
    let isNegative: Bool
    var createDate: Date = Date()
    var isEditMode: Bool = false // 코어데이터에 저장안되는 변수
    
    func updated(
        name: String? = nil,
        hex: Int? = nil,
        isNegative: Bool? = nil,
        createDate: Date? = nil,
        isEditMode: Bool? = nil
    ) -> Self {
        SymptomData(
            name: name ?? self.name,
            hex: hex ?? self.hex,
            isNegative: isNegative ?? self.isNegative,
            createDate: createDate ?? self.createDate,
            isEditMode: isEditMode ?? self.isEditMode
        )
    }
}

extension SymptomData: Equatable, IdentifiableType {
    // 이게 달라지면 rx데이터소스에서 insert처리
    var identity: Date {
        self.createDate
    }
    // 이게 false면 rx데이터소스에서 reload처리
    static func == (lhs: SymptomData, rhs: SymptomData) -> Bool {
        lhs.createDate == rhs.createDate && lhs.isEditMode == rhs.isEditMode
    }
}
