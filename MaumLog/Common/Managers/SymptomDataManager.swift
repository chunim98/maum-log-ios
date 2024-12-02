//
//  SymptomDataManager.swift
//  MaumLog
//
//  Created by 신정욱 on 8/17/24.
//

import UIKit
import CoreData

final class SymptomDataManager{
    
    static let shared  = SymptomDataManager()
    private init() {}
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private lazy var context = appDelegate?.persistentContainer.viewContext
    private let entityName = "SymptomCoreData"
    
    
    func read() -> [SymptomData] {
        let empty = [SymptomData]() // nil을 반환하는 것 보다 빈 배열 반환하는 게 나음
        guard let context = context else { return empty } // 임시 저장소 접근한다는 뜻
        
        let order = NSSortDescriptor(key: "createDate", ascending: true) // 어떤 친구 기준으로 소팅할건지?
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName) // 엔티티에 접근한다는 신청서
        request.sortDescriptors = [order] // 왠지 모르겠지만 얘는 배열에 담아서 줘야함
        
        do{
            guard let data = try context.fetch(request) as? [SymptomCoreData] else { return empty } // fetch() 무조건 배열만 리턴함
            return data.map{
                SymptomData(
                    name: $0.name,
                    hex: $0.hex.toInt,
                    isNegative: $0.isNegative,
                    createDate: $0.createDate)
            }
        }catch{
            print("읽기 실패")
            return empty
        }
    }
    
    
    func create(from: SymptomData) {
        guard let context = context else { return }
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return } // 임시저장소에 있는 데이터를 그려줄 형태 파악하기
        guard let object = NSManagedObject(entity: entity, insertInto: context) as? SymptomCoreData else { return } // 임시저장소에 올라가게 할 객체만들기
        // SymptomCoreData(context: context) 그냥 이렇게 만들어도 되긴 함
        
        // 실제 데이터 할당
        object.name = from.name
        object.hex = from.hex.to32
        object.isNegative = from.isNegative
        object.createDate = from.createDate
        
        appDelegate?.saveContext() // 앱델리게이트의 메서드로 해도됨
    }
    
    
    func delete(target: SymptomData) {
        guard let context = context else { return }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName) // 요청서
        // createDate기준으로 to.createDate 값과 같은 값이 들어있는 데이터만 가져오겠다~
        // 근데 같은 값이 있을리가 없으니 사실상 하나만 가져오겠다는 소리
        request.predicate = NSPredicate(format: "createDate = %@", target.createDate as CVarArg) // 스트링은 %@, 정수는 %d
        
        do {
            guard let data = try context.fetch(request) as? [SymptomCoreData] else { return }// 요청서를 통해서 데이터 가져오기 (무조건 배열로 가져오고, 조건 맞는 건 다 가져옴)
            data.forEach{ context.delete($0) } // 임시저장소에서 (요청서를 통해서) 데이터 삭제하기 (delete메서드)

            appDelegate?.saveContext() // 앱델리게이트의 메서드로 해도됨
        } catch {
            print("삭제 실패")
        }
    }
    
}
