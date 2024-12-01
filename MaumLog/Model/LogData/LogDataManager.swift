//
//  LogDataManager.swift
//  MaumLog
//
//  Created by 신정욱 on 8/17/24.
//

import UIKit
import CoreData

final class LogDataManager {
    
    static let shared  = LogDataManager()
    private init() {}
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private lazy var context = appDelegate?.persistentContainer.viewContext
    private let entityName = "LogCoreData"
    
    
    func read(ascending: Bool = false) -> [LogData] {
        let empty = [LogData]() // nil을 반환하는 것 보다 빈 배열 반환하는 게 나음
        guard let context = context else { return empty } // 임시 저장소 접근한다는 뜻
        
        let order = NSSortDescriptor(key: "date", ascending: ascending) // 어떤 친구 기준으로 소팅할건지?
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName) // 엔티티에 접근한다는 신청서
        request.sortDescriptors = [order] // 왠지 모르겠지만 얘는 배열에 담아서 줘야함
        
        do{
            guard let data = try context.fetch(request) as? [LogCoreData] else { return empty } // fetch() 무조건 배열만 리턴함
            
            let logData = data.map{
                let cardCoreData = ($0.symptomCards?.array as? [SymptomCardCoreData]) ?? [SymptomCardCoreData]() // 코어데이터 타입으로 캐스팅
                let cardData = cardCoreData.map { // 바깥에서 쓸 타입으로 map
                    SymptomCardData(
                        name: $0.name,
                        hex: $0.hex.toInt,
                        isNegative: $0.isNegative,
                        rate: $0.rate.toInt)
                }
                
                let medicineCardCoreData = ($0.medicineCards?.array as? [MedicineCardCoreData]) ?? [MedicineCardCoreData]() // 코어데이터 타입으로 캐스팅
                let medicineCardData = medicineCardCoreData.map { // 바깥에서 쓸 타입으로 map
                    MedicineCardData(name: $0.medicine)
                }
                
                return LogData(date: $0.date, symptomCards: cardData, medicineCards: medicineCardData)
            }
            
            return logData
        }catch{
            print("읽기 실패")
            return empty
        }
    }
    
    
    func create(from: [SymptomCardData]) {
        var cardDataArray = [SymptomCardCoreData]() // SymptomCardData 담을 배열 준비
        guard let context = context else { return }
        guard let logDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return } // 임시저장소에 있는 데이터를 그려줄 형태 파악하기
        guard let logDataObject = NSManagedObject(entity: logDataEntity, insertInto: context) as? LogCoreData else { return } // 임시저장소에 올라가게 할 객체만들기, LogCoreData(context: context) 그냥 이렇게 만들어도 되긴 함

        // 하위 엔티티 객체 만들어주고, 값 설정하기
        guard let cardDataEntity = NSEntityDescription.entity(forEntityName: "SymptomCardCoreData", in: context) else { return } // 하위 엔티티 만들고
        from.forEach { // 받아온 데이터들로 for문 돌려준다
            guard let cardDataObject = NSManagedObject(entity: cardDataEntity, insertInto: context) as? SymptomCardCoreData else { return } // CardData인스턴스 만들기(꼴랑 인스하나 만드는데 엄청 복잡하네;;)
            cardDataObject.name = $0.name
            cardDataObject.hex = $0.hex.to32
            cardDataObject.isNegative = $0.isNegative
            cardDataObject.rate = $0.rate.to16
            // 일단 배열에 담아주기
            cardDataArray.append(cardDataObject)
        }

        // 실제 데이터 할당
        logDataObject.date = Date()
        logDataObject.addToSymptomCards((NSOrderedSet(array: cardDataArray)))
        
        appDelegate?.saveContext() // 앱델리게이트의 메서드로 해도됨
    }
    
    
    func create(from: [MedicineCardData]) {
        var cardDataArray = [MedicineCardCoreData]() // SymptomCardData 담을 배열 준비
        guard let context = context else { return }
        guard let logDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return } // 임시저장소에 있는 데이터를 그려줄 형태 파악하기
        guard let logDataObject = NSManagedObject(entity: logDataEntity, insertInto: context) as? LogCoreData else { return } // 임시저장소에 올라가게 할 객체만들기, LogCoreData(context: context) 그냥 이렇게 만들어도 되긴 함

        // 하위 엔티티 객체 만들어주고, 값 설정하기
        guard let cardDataEntity = NSEntityDescription.entity(forEntityName: "MedicineCardCoreData", in: context) else { return } // 하위 엔티티 만들고
        from.forEach { // 받아온 데이터들로 for문 돌려준다
            guard let cardDataObject = NSManagedObject(entity: cardDataEntity, insertInto: context) as? MedicineCardCoreData else { return } // CardData인스턴스 만들기(꼴랑 인스하나 만드는데 엄청 복잡하네;;)
            cardDataObject.medicine = $0.name
            // 일단 배열에 담아주기
            cardDataArray.append(cardDataObject)
        }

        // 실제 데이터 할당
        logDataObject.date = Date()
        logDataObject.addToMedicineCards((NSOrderedSet(array: cardDataArray)))
        
        appDelegate?.saveContext() // 앱델리게이트의 메서드로 해도됨
    }
    
    
    func delete(target: LogData) {
        guard let context = context else { return }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName) // 요청서
        // date기준으로 from.date 값과 같은 값이 들어있는 데이터만 가져오겠다~
        // 근데 같은 같이 있을리가 없으니 사실상 하나만 가져오겠다는 소리
        request.predicate = NSPredicate(format: "date = %@", target.date as CVarArg) // 스트링은 %@, 정수는 %d
        
        do {
            guard let data = try context.fetch(request) as? [LogCoreData] else { return }// 요청서를 통해서 데이터 가져오기 (무조건 배열로 가져오고, 조건 맞는 건 다 가져옴)
            data.forEach{ context.delete($0) } // 임시저장소에서 (요청서를 통해서) 데이터 삭제하기 (delete메서드)
            
            appDelegate?.saveContext() // 앱델리게이트의 메서드로 해도됨
        } catch {
            print("삭제 실패")
        }
    }
    
    
    /// 테스트 못해봄, 사용하게 될 경우 테스트 해볼 것
    func update(target: LogData, from: [SymptomCardData]) {
        guard let context = context else { return }
        var replacementCardDataArr = [SymptomCardCoreData]() // 대체할 SymptomCardData 담을 배열 준비

        // 교체할 하위 엔티티 객체 값 설정하고 배열에 추가
        guard let cardDataEntity = NSEntityDescription.entity(forEntityName: "SymptomCardCoreData", in: context) else { return } // 하위 엔티티 만들고
        from.forEach { // 받아온 데이터들로 for문 돌려준다
            guard let cardDataObject = NSManagedObject(entity: cardDataEntity, insertInto: context) as? SymptomCardCoreData else { return } // CardData인스턴스 만들기(꼴랑 인스하나 만드는데 엄청 복잡하네;;)
            cardDataObject.name = $0.name
            cardDataObject.hex = $0.hex.to32
            cardDataObject.isNegative = $0.isNegative
            cardDataObject.rate = $0.rate.to16
            // 일단 배열에 담아주기
            replacementCardDataArr.append(cardDataObject)
        }
        
        // 상위 엔티티 객체 가져오기
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName) // 요청서
        request.predicate = NSPredicate(format: "date = %@", target.date as CVarArg) // 가져올 객체들의 조건 설정
        do {
            guard let logData = try context.fetch(request) as? [LogCoreData] else { return } // 요청서를 통해서 객체 가져오기
            for i in logData { i.addToSymptomCards((NSOrderedSet(array: replacementCardDataArr))) } // date는 냅두고 내부데이터만 업데이트
            
            appDelegate?.saveContext() // 앱델리게이트의 메서드로 해도됨
        } catch {
            print("업데이트 실패")
        }
    }
    
    
    func deleteAll(completion: (() -> ())? = nil) {
        guard let context = context else { return }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName) // 조건 걸어준 것이 없어서 있는 거 다 들고옴
        
        do {
            guard let logData = try context.fetch(request) as? [LogCoreData] else { return }// 요청서를 통해서 데이터 가져오기 (무조건 배열로 가져오고, 조건 맞는 건 다 가져옴)
            logData.forEach{ context.delete($0) } // 임시저장소에서 (요청서를 통해서) 데이터 삭제하기 (delete메서드)
            
            appDelegate?.saveContext() // 앱델리게이트의 메서드로 해도됨
            
            completion?() // 작업이 완료후 이벤트 처리할 거 있으면 하고, 아님 말고
        } catch {
            print("삭제 실패")
        }
    }
    
}
