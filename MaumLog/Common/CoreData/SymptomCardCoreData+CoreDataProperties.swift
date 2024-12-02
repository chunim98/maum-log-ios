//
//  SymptomCardCoreData+CoreDataProperties.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//
//

import Foundation
import CoreData


extension SymptomCardCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SymptomCardCoreData> {
        return NSFetchRequest<SymptomCardCoreData>(entityName: "SymptomCardCoreData")
    }

    @NSManaged public var hex: Int32
    @NSManaged public var isNegative: Bool
    @NSManaged public var name: String
    @NSManaged public var rate: Int16
    @NSManaged public var logData: LogCoreData?

}

extension SymptomCardCoreData : Identifiable {

}
