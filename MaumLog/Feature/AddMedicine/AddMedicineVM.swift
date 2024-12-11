//
//  AddMedicineVM.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import Combine

final class AddMedicineVM {
    
    /// 컴바인 퍼스트 파티라서 기대했는데, 오퍼레이터도 적고, RxCocoa같이 UIControl 래핑한 퍼블리셔 제공도 안해줌.
    ///
    /// RxCocoa의 부재 때문인지, eraseToAnyPublisher() 메서드를 일일이 뒤에 붙이는 게 번거로운 건지,
    /// 대부분 enum으로 이벤트 전달하는 in-out 패턴을 채용하고 있음. (UIKit + Combine 한정이지만)
    ///
    /// 이러면 스트림 병합을 못해서 외부에 상태 저장용, 중개용 서브젝트를 만들 수 밖에 없게 되고,
    /// 데이터 흐름을 파악하기가 힘들어짐.
    ///
    /// in-out 패턴이 아닌, 그저 @Published 래퍼를 써서 반응형으로 구현한다 하더라도
    /// 데이터 흐름 파악하기 힘든 건 마찬가지.
    ///
    /// 유킷에서 Combine을 쓰려고 하니까 이렇게 짜치는건가....?
    /// 스유 가져가도 크게 다를 것 같지는 않은데...
    
    enum Input {
        case tappedConfirmButton
        case textOfTextField(String)
        case tappedCloseButton
    }
    
    enum Output {
        case clippedText(String)
        case isEnabledConfirmButton(Bool)
        case justDismiss
        case presentDuplicateAlert(String)
        case saveAndDismiss
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        let output = PassthroughSubject<Output, Never>()

        // tappedConfirmButton 이벤트 중개
        let tappedConfirmButton = PassthroughSubject<Void, Never>()
        // 12자로 클리핑된 텍스트 중개
        let clippedText = PassthroughSubject<String, Never>()

        // input 이벤트 처리
        input.sink { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .tappedConfirmButton:
                tappedConfirmButton.send()
                
            case .textOfTextField(let text):
                clippedText.send(clip(this: text))
                
            case .tappedCloseButton:
                output.send(.justDismiss)
            }
        }
        .store(in: &cancellables)
        
        // 텍스트 필드에 공백을 제외한 텍스트 전달
        clippedText
            .sink { text in
                output.send(.clippedText(text))
            }
            .store(in: &cancellables)
        
        // 텍스트 필드에 뭐라도 쳐야 추가버튼 활성화
        clippedText
            .map { !($0.isEmpty) }
            .sink { bool in
                output.send(.isEnabledConfirmButton(bool))
            }
            .store(in: &cancellables)
        
        // 저장 버튼 눌렀을 때의 저장 로직
        // saveAndDismiss이 한 번은 방출 될 때까지 실행 안 될 것으로 예상
        tappedConfirmButton
            .combineLatest(clippedText)
            .sink { [weak self] _, name in
                guard let isDuplicated = self?.checkDuplicate(text: name) else { return }
                
                // 중복 체크 후 저장 or 중복 얼럿 띄우기
                if !isDuplicated {
                    MedicineDataManager.shared.create(from: MedicineData(name: name))
                    // 중복 얼럿 메시지 전송
                    output.send(.saveAndDismiss)
                } else {
                    // 저장 후 화면 닫기 메시지 전송
                    output.send(.presentDuplicateAlert(name))
                }
            }
            .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    // MARK: - Methods
    private func clip(this text: String) -> String {
        // 공백은 제거
        let text = text.trimmingCharacters(in: .whitespaces)
        
        // 텍스트 12글자 제한
        if text.count > 12 {
            let index = text.index(text.startIndex, offsetBy: 12)
            return String(text[..<index])
        } else {
            return text
        }
    }
    
    private func checkDuplicate(text: String) -> Bool {
        MedicineDataManager.shared.read().contains { $0.name == text }
    }
}
