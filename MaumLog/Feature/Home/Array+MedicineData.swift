//
//  Array+MedicineData.swift
//  MaumLog
//
//  Created by 신정욱 on 3/11/25.
//

import Foundation

extension Array where Element == MedicineData {
    var sectionDataArr: [MedicineSectionData] {
        [MedicineSectionData(items: self)]
    }
}

extension Array where Element == MedicineSectionData {
    var cellDataArr: [MedicineData] {
        self.first?.items ?? [MedicineData]()
    }
}
