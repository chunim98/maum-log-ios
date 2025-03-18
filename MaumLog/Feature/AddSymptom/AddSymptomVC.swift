//
//  AddSymptomVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/9/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class AddSymptomVC: UIViewController {
    
    // MARK: Properties
    
    private let addSymptomVM = AddSymptomVM()
    private let bag = DisposeBag()
    weak var coordinator: AddSymptomCoordinator?
    var dismissTask: (() -> Void)?
    
    // MARK: Components
    
    private let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    private let headerView = AddSymptomHeaderView()
    
    private let pickerTextFieldHStack = {
        let sv = UIStackView()
        sv.spacing = 15
        return sv
    }()
    
    private let colorPickerButton = {
        let button = UIColorWell()
        button.supportsAlpha = false // 색상피커에서 불투명도 옵션을 제거
        button.title = "색상 지정"
        return button
    }()
    
    fileprivate let capsuleTextField = CapsuleTextField()
    private let colorPaletteView = ColorPaletteView()
    private let confirmButton = ConfirmButton()
    
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
    
    func setAutoLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(headerView)
        mainVStack.addArrangedSubview(pickerTextFieldHStack)
        mainVStack.addArrangedSubview(colorPaletteView)
        mainVStack.addArrangedSubview(confirmButton)
        pickerTextFieldHStack.addArrangedSubview(colorPickerButton)
        pickerTextFieldHStack.addArrangedSubview(capsuleTextField)
        
        mainVStack.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(15)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).inset(-15)
        }
        headerView.snp.makeConstraints { $0.height.equalTo(30) }
        pickerTextFieldHStack.snp.makeConstraints { $0.height.equalTo(50) }
        colorPickerButton.snp.makeConstraints { $0.width.equalTo(50) }
        confirmButton.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    // MARK: Binding
    
    func setBinding() {
        let selectedColorFromPicker = colorPickerButton.rx.controlEvent(.valueChanged)
            .compactMap { [weak self] _ in self?.colorPickerButton.selectedColor }
        let selectedColorFromPalette = colorPaletteView.rx.selectedColor
        
        let input = AddSymptomVM.Input(
            closeButtonEvent: headerView.rx.closeButtonEvent,
            confirmButtonEvent: confirmButton.rx.event,
            clippedText: capsuleTextField.rx.clippedText,
            selectedColor: Observable.merge(selectedColorFromPicker, selectedColorFromPalette)
        )
        let output = addSymptomVM.transform(input)
        
        // 텍스트 필드가 채워지면, 추가 버튼 활성화
        output.isConfirmButtonEnabled
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: bag)

        // 화면 전환 이벤트 바인딩
        output.addSymptomEvent
            .debug()
            .bind(to: self.rx.addSymptomEvent)
            .disposed(by: bag)
        
        // 초기 색상, 업데이트 색상 바인딩
        output.selectedColor
            .bind(
                to: colorPickerButton.rx.selectedColor,
                capsuleTextField.rx.capsuleColor
            )
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    AddSymptomVC()
}

// MARK: - Reactive

extension Reactive where Base: AddSymptomVC {
    fileprivate var addSymptomEvent: Binder<AddSymptomEvent> {
        Binder(base) {
            switch $1 {
            case .save: // 저장하고 닫기
                HapticManager.shared.occurSuccess()
                $0.dismissTask?()
                $0.dismiss(animated: true)
                
            case .dismiss: // 저장 없이 닫기
                $0.dismiss(animated: true)
                
            case .presentDuplicateAlert(let name): // 중복 얼럿 표시
                $0.capsuleTextField.endEditing(true) // 표시 전 키보드 닫아줘야 함
                $0.presentAcceptAlert(
                    title: "등록 실패",
                    message: "\"\(name)\"은(는) 이미 등록된 이름이에요.\n다른 이름으로 다시 시도해주세요."
                )
            }
        }
    }
}
