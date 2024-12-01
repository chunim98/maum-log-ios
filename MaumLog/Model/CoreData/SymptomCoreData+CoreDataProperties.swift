//
//  SymptomCoreData+CoreDataProperties.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//
//

import Foundation
import CoreData


extension SymptomCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SymptomCoreData> {
        return NSFetchRequest<SymptomCoreData>(entityName: "SymptomCoreData")
    }

    @NSManaged public var createDate: Date
    @NSManaged public var hex: Int32
    @NSManaged public var isNegative: Bool
    @NSManaged public var name: String

}

extension SymptomCoreData : Identifiable {

}
