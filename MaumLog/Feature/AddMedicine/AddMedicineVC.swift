//
//  AddMedicineVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import SnapKit
import Combine

final class AddMedicineVC: UIViewController {
    
    private let addMedicineVM = AddMedicineVM()
    private var cancellables = Set<AnyCancellable>()
    var dismissTask: (() -> Void)?
    
    private let input = PassthroughSubject<AddMedicineVM.Input, Never>()
    
    // MARK: - Components
    let titleBackground = {
        let view = UIView()
        view.backgroundColor = .chuIvory
        return view
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "복용 중인 약 등록")
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .chuBlack
        label.textAlignment = .center
        return label
    }()
    
    let closeButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "x")?
            .resizeImage(newWidth: 22)
            .withRenderingMode(.alwaysTemplate)
        config.baseForegroundColor = .chuBlack
        return UIButton(configuration: config)
    }()
    
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = .chuSpace / 2
        return sv
    }()

    let capsuleView = {
        let view = UIView()
        view.backgroundColor = .chuBlack
        view.clipsToBounds = true
        view.layer.cornerRadius = 25
        return view
    }()
    
    let textField = {
        let tf = UITextField()
        tf.placeholder = String(localized: "약 이름 입력 (최대 12자)")
        tf.font = .boldSystemFont(ofSize: 20)
        tf.textColor = .chuBlack
        tf.textAlignment = .center
        tf.returnKeyType = .done // 키보드 리턴키를 "완료"로 변경
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .chuWhite
        return tf
    }()
    
    let stretchableView = UIView()

    let confirmButton = {
        var config = UIButton.Configuration.filled()
        config.title = String(localized: "추가")
        config.baseBackgroundColor = .chuBlack
        config.baseForegroundColor = .chuWhite
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        button.isEnabled = false
        return button
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        closeButton.addTarget(self, action: #selector(handleCloseButtonEvent), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(handleConfirmButtonEvent), for: .touchUpInside)
        textField.delegate = self
        
        setAutoLayout()
        setBinding()
    }
    
    // MARK: - Layout
    func setAutoLayout() {
        view.addSubview(mainVStack)
        view.addSubview(titleBackground)
        mainVStack.addArrangedSubview(capsuleView)
        mainVStack.addArrangedSubview(stretchableView)
        mainVStack.addArrangedSubview(confirmButton)
        capsuleView.addSubview(textField)
        titleBackground.addSubview(titleLabel)
        titleBackground.addSubview(closeButton)

        titleBackground.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: .chuSpace, bottom: 10, right: .chuSpace))
        }
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        mainVStack.snp.makeConstraints {
            $0.top.equalTo(titleBackground.snp.bottom).inset(CGFloat.chuSpace.reverse)
            $0.horizontalEdges.equalToSuperview().inset(CGFloat.chuSpace)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).inset(CGFloat.chuSpace.reverse) // 키보드 올라왔을 때 레이아웃 동적 변환
        }
        capsuleView.snp.makeConstraints { $0.height.equalTo(CGFloat.chuHeight) }
        textField.snp.makeConstraints { $0.centerX.centerY.equalToSuperview() }
        confirmButton.snp.makeConstraints { $0.height.equalTo(CGFloat.chuHeight) }
    }
    
    // MARK: - Binding
    func setBinding() {
        // Input
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.textField)
            .compactMap{ $0.object as? UITextField}
            .map{ $0.text ?? "" }
            .sink { [weak self] text in
                self?.input.send(.textOfTextField(text))
            }
            .store(in: &cancellables)
        
        
        let output = addMedicineVM.transform(input.eraseToAnyPublisher())
        
        output.sink { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .clippedText(let text):
                /// 텍스트 필드에 공백을 제외한 텍스트 바인딩
                textField.text = text
                
            case .isEnabledConfirmButton(let bool):
                /// 텍스트 필드에 뭐라도 쳐야 추가버튼 활성화
                confirmButton.isEnabled = bool
                
            case .justDismiss:
                /// 그냥 화면 닫기
                dismiss(animated: true)
                
            case .presentDuplicateAlert(let name):
                /// 중복 얼럿 띄우기
                
                // 얼럿 뜨기 전 키보드 닫아줘야 함
                textField.endEditing(true)
                // 얼럿 띄우기
                presentAcceptAlert(
                    title: String(localized: "등록 실패"),
                    message: String(localized: "\"\(name)\"은(는) 이미 등록된 이름이에요.\n다른 이름으로 다시 시도해주세요."))
                
            case .saveAndDismiss:
                /// 저장했으니 이제 화면 닫기
                HapticManager.shared.occurSuccess()
                dismissTask?()
                dismiss(animated: true)
            }
        }
        .store(in: &cancellables)
    }
    
    @objc private func handleConfirmButtonEvent() {
        input.send(.tappedConfirmButton)
    }
    
    @objc private func handleCloseButtonEvent() {
        input.send(.tappedCloseButton)
    }
}

extension AddMedicineVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        /// 키보드의 done 버튼을 누르면 키보드 닫기
        /// input으로 이벤트 안보내는 이유는 비효율적이라?
        
        textField.endEditing(true)
        return true
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    AddMedicineVC()
}
