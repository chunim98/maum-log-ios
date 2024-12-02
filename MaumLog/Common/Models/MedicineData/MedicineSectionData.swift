//
//  MedicineSectionData.swift
//  MaumLog
//
//  Created by 신정욱 on 8/27/24.
//

import Foundation
import Differentiator

struct MedicineSectionData: AnimatableSectionModelType {
    var items: [MedicineData]
    var identity: String = "NoneSection"
    
    
    init(original: MedicineSectionData, items: [MedicineData]) {
        self = original
        self.items = items
    }
    
    init(items: [MedicineData]){
        self.items = items
    }
}
