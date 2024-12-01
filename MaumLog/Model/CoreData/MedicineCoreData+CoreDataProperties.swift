//
//  MedicineCoreData+CoreDataProperties.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//
//

import Foundation
import CoreData


extension MedicineCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MedicineCoreData> {
        return NSFetchRequest<MedicineCoreData>(entityName: "MedicineCoreData")
    }

    @NSManaged public var createDate: Date
    @NSManaged public var name: String

}

extension MedicineCoreData : Identifiable {

}
