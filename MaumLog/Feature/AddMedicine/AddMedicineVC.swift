//
//  AddMedicineVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AddMedicineVC: UIViewController {
    
    private let addMedicineVM = AddMedicineVM()
    private let bag = DisposeBag()
    var dismissTask: (() -> Void)?
    
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
        // input ========================================
        textField
            .rx.text.orEmpty
            .bind(to: addMedicineVM.input.textOfTextField)
            .disposed(by: bag)
        
        textField
            .rx.controlEvent(.editingDidEndOnExit) // 키보드의 done버튼에 대응하는 이벤트
            .subscribe() // 그냥 키보드만 닫으려고..ㅎ
            .disposed(by: bag)
        
         confirmButton
            .rx.tap
            .bind(to: addMedicineVM.input.tappedConfirmButton)
            .disposed(by: bag)
        
        closeButton
            .rx.tap
            .bind(to: addMedicineVM.input.tappedCloseButton)
            .disposed(by: bag)
        
        //output ========================================
        addMedicineVM.output.clippedText
            .bind(to: textField.rx.text)
            .disposed(by: bag)
        
        
        addMedicineVM.output.isEnabledConfirmButton
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: bag)
        
        
        addMedicineVM.output.confirmWithIsDuplicated
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                guard let name = textField.text else { return }
                
                // 중복된 이름인지 아닌지
                if $0 {
                    // 얼럿 뜨기 전 키보드 닫아줘야 함
                    textField.endEditing(true)
                    // 얼럿 띄우기
                    presentAcceptAlert(
                        title: String(localized: "등록 실패"),
                        message: String(localized: "\"\(name)\"은(는) 이미 등록된 이름이에요.\n다른 이름으로 다시 시도해주세요."))
                } else {
                    // 복용중인 약 뷰에서 저장, 셀 리프레쉬는 홈 뷰(모델)에서 구현
                    MedicineDataManager.shared.create(from: .init(name: name))
                    HapticManager.shared.occurSuccess()
                    dismissTask?()
                    dismiss(animated: true)
                }
            })
            .disposed(by: bag)
        
        addMedicineVM.output.justDismiss
            .bind(onNext: { [weak self] in self?.dismiss(animated: true) })
            .disposed(by: bag)

    }
}

#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    AddMedicineVC()
}
