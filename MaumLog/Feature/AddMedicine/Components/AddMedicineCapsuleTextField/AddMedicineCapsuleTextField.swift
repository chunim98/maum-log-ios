//
//  AddMedicineCapsuleTextField.swift
//  MaumLog
//
//  Created by 신정욱 on 4/14/25.
//

import UIKit
import Combine

import SnapKit

final class AddMedicineCapsuleTextField: UIView {
    
    // MARK: Properties
    
    private var vm = AddMedicineCapsuleTextFieldVM()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Interface
    
    private let clippedText = PassthroughSubject<String, Never>()
    
    // MARK: Components
    
    private let mainHStack = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = .init(horizontal: 20, vertical: 7.5)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.backgroundColor = .chuBlack
        sv.layer.cornerRadius = 25
        sv.clipsToBounds = true
        return sv
    }()
    
    private let textField = {
        let tf = UITextField()
        tf.font = .boldSystemFont(ofSize: 20)
        tf.placeholder = "약 이름 입력 (최대 12자)"
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .chuWhite
        tf.textAlignment = .center
        tf.textColor = .chuBlack
        tf.returnKeyType = .done // 리턴키를 "완료"로 변경
        return tf
    }()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setAutoLayout() {
        self.addSubview(mainHStack)
        mainHStack.addArrangedSubview(textField)
        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: Binding
    
    private func setBinding() {
        let input = AddMedicineCapsuleTextFieldVM.Input(text: textField.textPublisher)
        let output = vm.transform(input)
        
        // 공백 제거된 텍스트를 텍스트 필드와 외부에 전달
        output.clippedText
            .sink { [weak self] in
                self?.textField.text = $0
                self?.clippedText.send($0)
            }
            .store(in: &cancellables)
        
        // 키보드의 done 버튼을 누르면 키보드 닫기
        textField.publisher(for: .editingDidEndOnExit)
            .sink { _ in }
            .store(in: &cancellables)
    }
}

// MARK: Public Publisher

extension AddMedicineCapsuleTextField {
    var clippedTextPublisher: AnyPublisher<String, Never> {
        clippedText.eraseToAnyPublisher()
    }
}

#Preview { AddMedicineCapsuleTextField() }
