//
//  AddSymptomVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/9/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AddSymptomVC: UIViewController {
    
    private let addSymptomVM = AddSymptomVM()
    private let bag = DisposeBag()
    var dismissTask: (() -> Void)?
    
    //MARK: - 컴포넌트
    let titleBackground = {
        let view = UIView()
        view.backgroundColor = .chuIvory
        return view
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "새 증상 등록")
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
    
    let overallSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = .chuSpace
        return sv
    }()
    
    let textFieldSV = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = .chuSpace
        return sv
    }()
    
    lazy var colorPickerButton = {
        let button = UIColorWell()
        button.addTarget(self, action: #selector(colorValueChanged), for: .valueChanged) // 이 구문 때문에 lazy 선언
        button.supportsAlpha = false // 색상피커에서 불투명도 옵션을 제거
        button.title = String(localized: "색상 지정")
        button.selectedColor = .chuColorPalette[1]
        return button
    }()
    
    let capsuleView = {
        let view = UIView()
        view.backgroundColor = .chuColorPalette[1]
        view.clipsToBounds = true
        view.layer.cornerRadius = 25
        return view
    }()
    
    let textField = {
        let tf = UITextField()
//        tf.attributedPlaceholder = NSAttributedString(
//            string: String(localized: "증상명 입력(6글자 제한)"),
//            attributes: [ // 플레이스 홀더 색상 커스텀
//                NSAttributedString.Key.foregroundColor : UIColor.chuHalfBlack,
//                NSAttributedString.Key.backgroundColor : UIColor.chuIvory ] )
        tf.placeholder = String(localized: "증상 입력 (최대 8자)")
        tf.font = .boldSystemFont(ofSize: 20)
        tf.textColor = .chuBlack
        tf.textAlignment = .center
        tf.returnKeyType = .done // 키보드 리턴키를 "완료"로 변경
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .chuWhite
        return tf
    }()
    
    let colorPaletteCVBackgroundView = {
        let view = UIView()
        view.backgroundColor = .chuWhite
        view.clipsToBounds = true
        view.layer.cornerRadius = 25
        return view
    }()
    
    let colorPaletteCV: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.register(ColorPaletteCell.self, forCellWithReuseIdentifier: ColorPaletteCell.identifier) // 셀의 등록과정 (스토리보드 사용시에는 스토리보드에서 자동등록)
        cv.showsVerticalScrollIndicator = false // 스크롤 바 숨기기
        cv.backgroundColor = .chuWhite
        cv.clipsToBounds = true
        cv.layer.cornerRadius = 15
        return cv
    }()
    
    let confirmButtonSV = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = .chuSpace
        sv.distribution = .fillEqually
        sv.layer.cornerRadius = 25
        sv.clipsToBounds = true
        return sv
    }()
    
    let negativeConfirmButton = {
        var config = UIButton.Configuration.filled()
        config.title = String(localized: "부작용으로 추가")
        config.baseBackgroundColor = .chuBadRate
        config.baseForegroundColor = .chuWhite
        config.cornerStyle = .small
        let button = UIButton(configuration: config)
        button.isEnabled = false
        return button
    }()
    
    let otherConfirmButton = {
        var config = UIButton.Configuration.filled()
        config.title = String(localized: "기타 증상으로 추가")
        config.baseBackgroundColor = .chuOtherRate
        config.baseForegroundColor = .chuWhite
        config.cornerStyle = .small
        let button = UIButton(configuration: config)
        button.isEnabled = false
        return button
    }()

    //MARK: - 라이프 사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        setAutoLayout()
        setBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 프레임 사이즈 확정이 좀 느린건지 모르겠지만 layoutIfNeeded()해줘야함
        colorPaletteCV.layoutIfNeeded()
        setColorPaletteCVLayout()
    }
    
    //MARK: - 오토레이아웃
    func setAutoLayout() {
        view.addSubview(overallSV)
        view.addSubview(titleBackground)
        titleBackground.addSubview(titleLabel)
        titleBackground.addSubview(closeButton)
        
        overallSV.addArrangedSubview(textFieldSV)
        textFieldSV.addArrangedSubview(colorPickerButton)
        textFieldSV.addArrangedSubview(capsuleView)
        capsuleView.addSubview(textField)
        overallSV.addArrangedSubview(colorPaletteCVBackgroundView)
        colorPaletteCVBackgroundView.addSubview(colorPaletteCV)
        overallSV.addArrangedSubview(confirmButtonSV)
        confirmButtonSV.addArrangedSubview(negativeConfirmButton)
        confirmButtonSV.addArrangedSubview(otherConfirmButton)

        
        titleBackground.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: .chuSpace, bottom: 10, right: .chuSpace))
        }
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        overallSV.snp.makeConstraints { make in
            make.top.equalTo(titleBackground.snp.bottom).inset(CGFloat.chuSpace.reverse)
            make.horizontalEdges.equalToSuperview().inset(CGFloat.chuSpace)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).inset(CGFloat.chuSpace.reverse) // 키보드 올라왔을 때 레이아웃 동적 변환
        }

        textField.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        colorPickerButton.snp.makeConstraints { make in
            make.width.height.equalTo(CGFloat.chuHeight)
        }
        colorPaletteCV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        confirmButtonSV.snp.makeConstraints { make in
            make.height.equalTo(CGFloat.chuHeight)
        }
        
    }
    
    //MARK: - 바인딩
    func setBinding() {
        // input
        textField
            .rx.text.orEmpty
            .bind(to: addSymptomVM.input.textOfTextField)
            .disposed(by: bag)
        
        textField
            .rx.controlEvent(.editingDidEndOnExit) // 키보드의 done버튼에 대응하는 이벤트
            .subscribe() // 그냥 키보드만 닫으려고..ㅎ
            .disposed(by: bag)
        
        negativeConfirmButton
            .rx.tap
            .bind(to: addSymptomVM.input.tappedNegativeConfirmButton)
            .disposed(by: bag)
        
        otherConfirmButton
            .rx.tap
            .bind(to: addSymptomVM.input.tappedOtherConfirmButton)
            .disposed(by: bag)
        
        closeButton
            .rx.tap
            .bind(to: addSymptomVM.input.tappedCloseButton)
            .disposed(by: bag)
        
        //output
        addSymptomVM.output.colorPaletteData
            .bind(to: colorPaletteCV.rx.items(cellIdentifier: ColorPaletteCell.identifier, cellType: ColorPaletteCell.self)) { index, item, cell in
                cell.setColorButton(hex: item)
                cell.colorButtonTask = { [weak self] in
                    self?.capsuleView.backgroundColor = item.toUIColor
                    self?.colorPickerButton.selectedColor = item.toUIColor
                }
            }
            .disposed(by: bag)
        
        
        addSymptomVM.output.clippedText
            .bind(to: textField.rx.text)
            .disposed(by: bag)
        
        
        addSymptomVM.output.isEnabledConfirmButton
            .bind(to: negativeConfirmButton.rx.isEnabled, otherConfirmButton.rx.isEnabled)
            .disposed(by: bag)
        
        
        addSymptomVM.output.negativeConfirmWithIsDuplicated
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                guard let name = textField.text else { return }
                guard let color = colorPickerButton.selectedColor else { return }
                
                // 중복된 이름인지 아닌지
                if $0 {
                    // 얼럿 뜨기 전 키보드 닫아줘야 함
                    textField.endEditing(true)
                    // 얼럿 띄우기
                    presentAcceptAlert(
                        title: String(localized: "등록 실패"),
                        message: String(localized: "\"\(name)\"은(는) 이미 등록된 이름이에요.\n다른 이름으로 다시 시도해주세요."))
                }else{
                    // 증상 등록 뷰에서 저장, 셀 리프레쉬는 홈 뷰(모델)에서 구현
                    SymptomDataManager.shared.create(from: .init(name: name, hex: color.toHexInt, isNegative: true))
                    HapticManager.shared.occurSuccess()
                    dismissTask?()
                    dismiss(animated: true)
                }
            })
            .disposed(by: bag)
        
        
        addSymptomVM.output.otherConfirmWithIsDuplicated
            .bind(onNext: { [weak self] in
                guard let self else { return }
                guard let name = textField.text else { return }
                guard let color = colorPickerButton.selectedColor else { return }
                
                // 중복된 이름인지 아닌지
                if $0 {
                    // 얼럿 뜨기 전 키보드 닫아줘야 함
                    textField.endEditing(true)
                    // 얼럿 띄우기
                    presentAcceptAlert(
                        title: String(localized: "등록 실패"),
                        message: String(localized: "\"\(name)\"은(는) 이미 등록된 이름이에요.\n다른 이름으로 다시 시도해주세요."))
                }else{
                    // 증상 등록 뷰에서 저장, 셀 리프레쉬는 홈 뷰(모델)에서 구현
                    SymptomDataManager.shared.create(from: .init(name: name, hex: color.toHexInt, isNegative: false))
                    HapticManager.shared.occurSuccess()
                    dismissTask?()
                    dismiss(animated: true)
                }
            })
            .disposed(by: bag)
        
        
        addSymptomVM.output.justDismiss
            .bind(onNext: { [weak self] in self?.dismiss(animated: true) })
            .disposed(by: bag)
        
        
        // 뷰가 띄워질 때, 매번 선택된 색이 달라지게 함
        addSymptomVM.output.setDefaultColor
            .bind(to: colorPickerButton.rx.selectedColor, capsuleView.rx.backgroundColor)
            .disposed(by: bag)
    }

    
    @objc private func colorValueChanged() {
        capsuleView.backgroundColor = colorPickerButton.selectedColor
    }
    
    
    private func setColorPaletteCVLayout() {
        colorPaletteCV.setMultilineLayout(spacing: .chuSpace, itemCount: 6)
    }
}


#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    AddSymptomVC()
}
