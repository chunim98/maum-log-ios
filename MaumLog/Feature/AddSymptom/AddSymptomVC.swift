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
    private let once = OnlyOnce()
    var dismissTask: (() -> Void)?
    
    private let selectedColorFromPalette = PublishSubject<UIColor>()
    
    // MARK: - Components
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
    
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = .chuSpace
        return sv
    }()
    
    let textFieldHStack = {
        let sv = UIStackView()
        sv.spacing = .chuSpace
        return sv
    }()
    
    let colorPickerButton = {
        let button = UIColorWell()
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
        // tf.attributedPlaceholder = NSAttributedString(
        //     string: String(localized: "증상명 입력(6글자 제한)"),
        //     attributes: [ // 플레이스 홀더 색상 커스텀
        //         NSAttributedString.Key.foregroundColor : UIColor.chuHalfBlack,
        //         NSAttributedString.Key.backgroundColor : UIColor.chuIvory ] )
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
    
    let confirmButtonHStack = {
        let sv = UIStackView()
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

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        setAutoLayout()
        setBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        once.excute {
            colorPaletteCV.layoutIfNeeded()
            setColorPaletteCVLayout()
        }
    }
    
    // MARK: - Layout
    func setAutoLayout() {
        view.addSubview(mainVStack)
        view.addSubview(titleBackground)
        mainVStack.addArrangedSubview(textFieldHStack)
        mainVStack.addArrangedSubview(colorPaletteCVBackgroundView)
        mainVStack.addArrangedSubview(confirmButtonHStack)
        textFieldHStack.addArrangedSubview(colorPickerButton)
        textFieldHStack.addArrangedSubview(capsuleView)
        colorPaletteCVBackgroundView.addSubview(colorPaletteCV)
        confirmButtonHStack.addArrangedSubview(negativeConfirmButton)
        confirmButtonHStack.addArrangedSubview(otherConfirmButton)
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
        textField.snp.makeConstraints { $0.centerX.centerY.equalToSuperview() }
        colorPickerButton.snp.makeConstraints { $0.width.height.equalTo(CGFloat.chuHeight) }
        colorPaletteCV.snp.makeConstraints { $0.edges.equalToSuperview().inset(10) }
        confirmButtonHStack.snp.makeConstraints { $0.height.equalTo(CGFloat.chuHeight) }
    }
    
    private func setColorPaletteCVLayout() {
        colorPaletteCV.setMultilineLayout(spacing: .chuSpace, itemCount: 6)
    }
    
    // MARK: - Binding
    func setBinding() {
        let selectedColorFromPicker = colorPickerButton
            .rx.controlEvent(.valueChanged)
            .map { [weak self] _ in self?.colorPickerButton.selectedColor }
            .compactMap { $0 }
                
        let input = AddSymptomVM.Input(
            tappedNegativeConfirmButton: negativeConfirmButton.rx.tap.asObservable(),
            tappedOtherConfirmButton: otherConfirmButton.rx.tap.asObservable(),
            textOfTextField: textField.rx.text.orEmpty.asObservable(),
            tappedCloseButton: closeButton.rx.tap.asObservable(),
            selectedColorFromPalette: selectedColorFromPalette.asObservable(),
            selectedColorFromPicker: selectedColorFromPicker)
        
        let output = addSymptomVM.transform(input)
        
        // 컬러 팔레트 컬렉션 뷰 데이터 소스
        output.colorPaletteData
            .bind(to: colorPaletteCV.rx.items(cellIdentifier: ColorPaletteCell.identifier, cellType: ColorPaletteCell.self)) { index, item, cell in
                cell.configure(hex: item)
                cell.colorButtonTask = { [weak self] in self?.selectedColorFromPalette.onNext(item.toUIColor) }
            }
            .disposed(by: bag)
        
        // 텍스트 필드에 공백을 제외한 텍스트 바인딩
        output.clippedText
            .bind(to: textField.rx.text)
            .disposed(by: bag)
        
        // 텍스트 필드에 뭐라도 쳐야 추가버튼 활성화
        output.isEnabledConfirmButton
            .bind(to: negativeConfirmButton.rx.isEnabled, otherConfirmButton.rx.isEnabled)
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
            .bind(onNext: { [weak self] in self?.dismiss(animated: true) })
            .disposed(by: bag)
        
        // 초기 색상, 업데이트 색상 바인딩
        output.selectedColor
            .bind(to: colorPickerButton.rx.selectedColor, capsuleView.rx.backgroundColor)
            .disposed(by: bag)
        
        // 키보드의 done 버튼을 누르면 키보드 닫기
        textField
            .rx.controlEvent(.editingDidEndOnExit)
            .subscribe()
            .disposed(by: bag)
    }

}


#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    AddSymptomVC()
}
