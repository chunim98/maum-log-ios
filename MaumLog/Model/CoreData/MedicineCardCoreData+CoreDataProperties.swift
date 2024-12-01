//
//  MedicineCardCoreData+CoreDataProperties.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//
//

import Foundation
import CoreData


extension MedicineCardCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MedicineCardCoreData> {
        return NSFetchRequest<MedicineCardCoreData>(entityName: "MedicineCardCoreData")
    }

    @NSManaged public var medicine: String
    @NSManaged public var logData: LogCoreData?

}

extension MedicineCardCoreData : Identifiable {

}
