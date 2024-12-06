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
        let input = AddMedicineVM.Input(
            tappedConfirmButton: confirmButton.rx.tap.asObservable(),
            textOfTextField: textField.rx.text.orEmpty.asObservable(),
            tappedCloseButton: closeButton.rx.tap.asObservable())
        
        let output = addMedicineVM.transform(input)
        
        // 텍스트 필드에 공백을 제외한 텍스트 바인딩
        output.clippedText
            .bind(to: textField.rx.text)
            .disposed(by: bag)
        
        // 텍스트 필드에 뭐라도 쳐야 추가버튼 활성화
        output.isEnabledConfirmButton
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: bag)
        
        // 중복 얼럿 띄우기
        output.presentDuplicateAlert
            .bind(with: self) { owner, name in
                // 얼럿 뜨기 전 키보드 닫아줘야 함
                owner.textField.endEditing(true)
                // 얼럿 띄우기
                owner.presentAcceptAlert(
                    title: String(localized: "등록 실패"),
                    message: String(localized: "\"\(name)\"은(는) 이미 등록된 이름이에요.\n다른 이름으로 다시 시도해주세요."))
            }
            .disposed(by: bag)
        
        // 저장했으니 이제 화면 닫기
        output.saveAndDismiss
            .bind(with: self) { owenr, _ in
                HapticManager.shared.occurSuccess()
                owenr.dismissTask?()
                owenr.dismiss(animated: true)
            }
            .disposed(by: bag)
        
        // 그냥 화면 닫기
        output.justDismiss
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: bag)
        
        // 키보드의 done 버튼을 누르면 키보드 닫기
        textField
            .rx.controlEvent(.editingDidEndOnExit)
            .subscribe()
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    AddMedicineVC()
}
