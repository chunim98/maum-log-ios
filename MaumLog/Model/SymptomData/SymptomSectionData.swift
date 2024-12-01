//
//  SymptomSectionData.swift
//  MaumLog
//
//  Created by 신정욱 on 8/27/24.
//

import Foundation
import Differentiator

struct SymptomSectionData: AnimatableSectionModelType {
    var items: [SymptomData]
    var identity: String = "NoneSection"
    
    
    init(original: SymptomSectionData, items: [SymptomData]) {
        self = original
        self.items = items
    }
    
    init(items: [SymptomData]){
        self.items = items
    }
}


