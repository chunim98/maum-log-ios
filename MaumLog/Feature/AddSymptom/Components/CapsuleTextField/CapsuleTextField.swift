//
//  CapsuleTextField.swift
//  MaumLog
//
//  Created by 신정욱 on 3/15/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class CapsuleTextField: UIView {
    
    // MARK: Properties
    
    private let capsuleTextFieldVM = CapsuleTextFieldVM()
    private let bag = DisposeBag()
    
    // MARK: Interface
    
    fileprivate let clippedText = PublishSubject<String>()
    
    // MARK: Components
    
    fileprivate let mainVStack = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = .init(horizontal: 20, vertical: 7.5)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.backgroundColor = .chuTint // temp
        sv.layer.cornerRadius = 25
        sv.clipsToBounds = true
        return sv
    }()
    
    fileprivate let textField = {
        let tf = UITextField()
        tf.font = .boldSystemFont(ofSize: 20)
        tf.placeholder = "증상 입력 (최대 8자)"
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
        self.addSubview(mainVStack)
        mainVStack.addArrangedSubview(textField)
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: Binding
    
    private func setBinding() {
        let input = CapsuleTextFieldVM.Input(text: textField.rx.text.orEmpty.asObservable())
        let output = capsuleTextFieldVM.transform(input)
        
        // 공백 제거된 텍스트를 텍스트 필드와 외부에 전달
        output.clippedText
            .bind(
                to: clippedText.asObserver(),
                textField.rx.text.orEmpty.asObserver()
            )
            .disposed(by: bag)
        
        // 키보드의 done 버튼을 누르면 키보드 닫기
        textField
            .rx.controlEvent(.editingDidEndOnExit)
            .subscribe()
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 200, height: 50)) {
    CapsuleTextField()
}

// MARK: - Reactive

extension Reactive where Base: CapsuleTextField {
    var capsuleColor: Binder<UIColor?> {
        Binder(base) { $0.mainVStack.backgroundColor = $1 }
    }

    var clippedText: Observable<String> {
        base.clippedText.asObservable().distinctUntilChanged()
    }
}
