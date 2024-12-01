//
//  LogCoreData+CoreDataProperties.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//
//

import Foundation
import CoreData


extension LogCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogCoreData> {
        return NSFetchRequest<LogCoreData>(entityName: "LogCoreData")
    }

    @NSManaged public var date: Date
    @NSManaged public var symptomCards: NSOrderedSet?
    @NSManaged public var medicineCards: NSOrderedSet?

}

// MARK: Generated accessors for symptomCards
extension LogCoreData {

    @objc(insertObject:inSymptomCardsAtIndex:)
    @NSManaged public func insertIntoSymptomCards(_ value: SymptomCardCoreData, at idx: Int)

    @objc(removeObjectFromSymptomCardsAtIndex:)
    @NSManaged public func removeFromSymptomCards(at idx: Int)

    @objc(insertSymptomCards:atIndexes:)
    @NSManaged public func insertIntoSymptomCards(_ values: [SymptomCardCoreData], at indexes: NSIndexSet)

    @objc(removeSymptomCardsAtIndexes:)
    @NSManaged public func removeFromSymptomCards(at indexes: NSIndexSet)

    @objc(replaceObjectInSymptomCardsAtIndex:withObject:)
    @NSManaged public func replaceSymptomCards(at idx: Int, with value: SymptomCardCoreData)

    @objc(replaceSymptomCardsAtIndexes:withSymptomCards:)
    @NSManaged public func replaceSymptomCards(at indexes: NSIndexSet, with values: [SymptomCardCoreData])

    @objc(addSymptomCardsObject:)
    @NSManaged public func addToSymptomCards(_ value: SymptomCardCoreData)

    @objc(removeSymptomCardsObject:)
    @NSManaged public func removeFromSymptomCards(_ value: SymptomCardCoreData)

    @objc(addSymptomCards:)
    @NSManaged public func addToSymptomCards(_ values: NSOrderedSet)

    @objc(removeSymptomCards:)
    @NSManaged public func removeFromSymptomCards(_ values: NSOrderedSet)

}

// MARK: Generated accessors for medicineCards
extension LogCoreData {

    @objc(insertObject:inMedicineCardsAtIndex:)
    @NSManaged public func insertIntoMedicineCards(_ value: MedicineCardCoreData, at idx: Int)

    @objc(removeObjectFromMedicineCardsAtIndex:)
    @NSManaged public func removeFromMedicineCards(at idx: Int)

    @objc(insertMedicineCards:atIndexes:)
    @NSManaged public func insertIntoMedicineCards(_ values: [MedicineCardCoreData], at indexes: NSIndexSet)

    @objc(removeMedicineCardsAtIndexes:)
    @NSManaged public func removeFromMedicineCards(at indexes: NSIndexSet)

    @objc(replaceObjectInMedicineCardsAtIndex:withObject:)
    @NSManaged public func replaceMedicineCards(at idx: Int, with value: MedicineCardCoreData)

    @objc(replaceMedicineCardsAtIndexes:withMedicineCards:)
    @NSManaged public func replaceMedicineCards(at indexes: NSIndexSet, with values: [MedicineCardCoreData])

    @objc(addMedicineCardsObject:)
    @NSManaged public func addToMedicineCards(_ value: MedicineCardCoreData)

    @objc(removeMedicineCardsObject:)
    @NSManaged public func removeFromMedicineCards(_ value: MedicineCardCoreData)

    @objc(addMedicineCards:)
    @NSManaged public func addToMedicineCards(_ values: NSOrderedSet)

    @objc(removeMedicineCards:)
    @NSManaged public func removeFromMedicineCards(_ values: NSOrderedSet)

}

extension LogCoreData : Identifiable {

}
