//
//  AddMedicineVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import Combine

import SnapKit

final class AddMedicineVC: UIViewController {
    
    // MARK: Properties
    
    private let addMedicineVM = AddMedicineVM()
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: AddMedicineCoordinator?
    var dismissTask: (() -> Void)?
    
    // MARK: Components
    
    private let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()

    private let headerView = AddMedicineHeaderView()
    
    private let capsuleTextField = AddMedicineCapsuleTextField()
    
    private let confirmButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .chuBlack
        config.baseForegroundColor = .chuWhite
        config.cornerStyle = .capsule
        config.title = "추가"
        let button = UIButton(configuration: config)
        button.isEnabled = false
        return button
    }()

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        setAutoLayout()
        setBinding()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.finish()
    }
    
    // MARK: Layout
    
    private func setAutoLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(headerView)
        mainVStack.addArrangedSubview(capsuleTextField)
        mainVStack.addArrangedSubview(UIView())
        mainVStack.addArrangedSubview(confirmButton)

        mainVStack.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(15)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).inset(-15)
        }
        capsuleTextField.snp.makeConstraints { $0.height.equalTo(50) }
        confirmButton.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    // MARK: Binding
    
    private func setBinding() {
        let confirmButtonEventPublisher = confirmButton
            .publisher(for: .touchUpInside)
            .map { _ in }
            .eraseToAnyPublisher()
        
        let input = AddMedicineVM.Input(
            closeButtonEvent: headerView.closeButtonEventPublisher,
            clippedText: capsuleTextField.clippedTextPublisher,
            confirmButtonEvent: confirmButtonEventPublisher
        )
        let output = addMedicineVM.transform(input)
        
        // 텍스트 필드가 채워지면, 추가 버튼 활성화
        output.isConfirmButtonEnabled
            .sink { [weak self] in self?.confirmButton.isEnabled = $0 }
            .store(in: &cancellables)
        
        // 화면 전환 이벤트 바인딩
        output.addMedicineEvent
            .sink { [weak self] in self?.handleAddMedicineEvent($0) }
            .store(in: &cancellables)
    }
}

// MARK: - Event Handling

extension AddMedicineVC {
    private func handleAddMedicineEvent(_ event: AddMedicineEvent) {
        switch event {
        // 저장하고 닫기
        case .save:
            HapticManager.shared.occurSuccess()
            dismissTask?()
            dismiss(animated: true)
            
        // 저장 없이 닫기
        case .dismiss:
            dismiss(animated: true)
            
        // 중복 얼럿 표시
        case .presentDuplicateAlert(let name):
            capsuleTextField.endEditing(true) // 표시 전 키보드 닫아줘야 함
            presentAcceptAlert(
                title: "등록 실패",
                message: "\"\(name)\"은(는) 이미 등록된 이름이에요.\n다른 이름으로 다시 시도해주세요."
            )
        }
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    AddMedicineVC()
}
