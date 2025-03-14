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
    var dismissTask: (() -> Void)?
    
    // MARK: Components
    
    private let titleBackground = {
        let view = UIView()
        view.backgroundColor = .chuIvory
        return view
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .chuBlack
        label.text = "새 증상 등록"
        return label
    }()
    
    private let closeButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "x")?
            .withRenderingMode(.alwaysTemplate)
            .resizeImage(newWidth: 22)
        config.baseForegroundColor = .chuBlack
        return UIButton(configuration: config)
    }()
    
    private let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    private let textFieldHStack = {
        let sv = UIStackView()
        sv.spacing = 15
        return sv
    }()
    
    private let colorPickerButton = {
        let button = UIColorWell()
        button.selectedColor = .chuColorPalette[1]
        button.supportsAlpha = false // 색상피커에서 불투명도 옵션을 제거
        button.title = "색상 지정"
        return button
    }()
    
    private let capsuleTextField = CapsuleTextField()
    
    private let colorPaletteView = ColorPaletteView()
    
    private let confirmButtonHStack = {
        let sv = UIStackView()
        sv.distribution = .fillEqually
        sv.layer.cornerRadius = 25
        sv.clipsToBounds = true
        sv.spacing = 15
        return sv
    }()
    
    private let negativeConfirmButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .chuBadRate
        config.baseForegroundColor = .chuWhite
        config.title = "부작용으로 추가"
        config.cornerStyle = .small
        
        let button = UIButton(configuration: config)
        button.isEnabled = false
        return button
    }()
    
    private let otherConfirmButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .chuOtherRate
        config.baseForegroundColor = .chuWhite
        config.title = "기타 증상으로 추가"
        config.cornerStyle = .small
        
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
    
    // MARK: Layout
    
    func setAutoLayout() {
        view.addSubview(mainVStack)
        view.addSubview(titleBackground)
        mainVStack.addArrangedSubview(textFieldHStack)
        mainVStack.addArrangedSubview(colorPaletteView)
        mainVStack.addArrangedSubview(confirmButtonHStack)
        textFieldHStack.addArrangedSubview(colorPickerButton)
        textFieldHStack.addArrangedSubview(capsuleTextField)
        confirmButtonHStack.addArrangedSubview(negativeConfirmButton)
        confirmButtonHStack.addArrangedSubview(otherConfirmButton)
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
        colorPickerButton.snp.makeConstraints { $0.width.height.equalTo(CGFloat.chuHeight) }
        confirmButtonHStack.snp.makeConstraints { $0.height.equalTo(CGFloat.chuHeight) }
    }
    
    // MARK: Binding
    
    func setBinding() {
        let selectedColorFromPicker = colorPickerButton
            .rx.controlEvent(.valueChanged)
            .compactMap { [weak self] _ in self?.colorPickerButton.selectedColor }
                
        let input = AddSymptomVM.Input(
            tappedNegativeConfirmButton: negativeConfirmButton.rx.tap.asObservable(),
            tappedOtherConfirmButton: otherConfirmButton.rx.tap.asObservable(),
            textOfTextField: capsuleTextField.rx.clippedText,
            tappedCloseButton: closeButton.rx.tap.asObservable(),
            selectedColorFromPalette: colorPaletteView.rx.selectedColor,
            selectedColorFromPicker: selectedColorFromPicker)
        
        let output = addSymptomVM.transform(input)
        
        // 텍스트 필드에 뭐라도 쳐야 추가버튼 활성화
        output.isEnabledConfirmButton
            .bind(to: negativeConfirmButton.rx.isEnabled, otherConfirmButton.rx.isEnabled)
            .disposed(by: bag)
        
        // 중복 얼럿 띄우기
        output.presentDuplicateAlert
            .bind(with: self) { owner, name in
                // 얼럿 뜨기 전 키보드 닫아줘야 함
                owner.capsuleTextField.endEditing(true)
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
            .bind(onNext: { [weak self] in self?.dismiss(animated: true) })
            .disposed(by: bag)
        
        // 초기 색상, 업데이트 색상 바인딩
        output.selectedColor
            .bind(to: colorPickerButton.rx.selectedColor, capsuleTextField.rx.capsuleColor)
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    AddSymptomVC()
}
