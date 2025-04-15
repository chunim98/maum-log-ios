//
//  AddMedicineVM.swift
//  MaumLog
//
//  Created by 신정욱 on 4/14/25.
//

import UIKit
import Combine

final class AddMedicineVM {
    
    // MARK: Input & Output
    
    struct Input {
        let closeButtonEvent: AnyPublisher<AddMedicineEvent, Never>
        let clippedText: AnyPublisher<String, Never>
        let confirmButtonEvent: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let isConfirmButtonEnabled: AnyPublisher<Bool, Never>
        let addMedicineEvent: AnyPublisher<AddMedicineEvent, Never>
    }
    
    // MARK: Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Transform
    
    func transform(_ input: Input) -> Output {
        let medicineDataArr = MedicineDataManager.shared.read()
        var clippedText = ""
        
        // 전역변수 clippedText 값 업데이트
        input.clippedText
            .sink { clippedText = $0 }
            .store(in: &cancellables)
        
        // 텍스트 필드가 채워지면, 추가 버튼 활성화
        let isConfirmButtonEnabled = input.clippedText
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()

        // 확인 버튼이 눌렸을 때, 데이터의 중복 여부에 따라 다른 이벤트 방출
        let confirmButtonEvent = input.confirmButtonEvent
            .compactMap { [weak self] _ in
                self?.attemptToAddMedicine(clippedText, medicineDataArr)
            }
            .eraseToAnyPublisher()
        
        // 확인 버튼과 닫기 버튼의 스트림을 병합
        let addMedicineEvent = confirmButtonEvent
            .merge(with: input.closeButtonEvent)
            .eraseToAnyPublisher()
        
        return Output(
            isConfirmButtonEnabled: isConfirmButtonEnabled,
            addMedicineEvent: addMedicineEvent
        )
    }
    
    // MARK: Methods
    
    private func attemptToAddMedicine(
        _ clippedText: String,
        _ medicineDataArr: [MedicineData]
    ) -> AddMedicineEvent {
        guard !medicineDataArr.contains(where: { $0.name == clippedText }) else {
            return .presentDuplicateAlert(clippedText)
        }
        
        let medicineData = MedicineData(name: clippedText)
        MedicineDataManager.shared.create(from: medicineData)
        return .save
    }
}
