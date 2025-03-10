//
//  Array+SymptomData.swift
//  MaumLog
//
//  Created by 신정욱 on 3/10/25.
//

import Foundation

extension Array where Element == SymptomData {
    var sectionDataArr: [SymptomSectionData] {
        [SymptomSectionData(items: self)]
    }
}

extension Array where Element == SymptomSectionData {
    var cellDataArr: [SymptomData] {
        self.first?.items ?? [SymptomData]()
    }
}
