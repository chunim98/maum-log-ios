//
//  SymptomSectionView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/18/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class SymptomSectionView: UIView {

    // MARK: Properties
    
    fileprivate let symptomSectionVM = SymptomSectionVM()
    fileprivate let bag = DisposeBag()
    
    // MARK: Components
    
    private let sectionView = SectionView()
    fileprivate let headerView = SectionHeaderView("등록된 증상")
    fileprivate let bodyView = SymptomSectionBodyView()

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
        self.addSubview(sectionView)
        sectionView.headerVStack.addArrangedSubview(headerView)
        sectionView.bodyVStack.addArrangedSubview(bodyView)

        sectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: Binding
    
    private func setBinding() {
        let input = SymptomSectionVM.Input(
            editButtonTapEvent: headerView.rx.editButtonTapEvent
        )
        let output = symptomSectionVM.transform(input: input)
        
        // 편집 상태 바인딩
        output.isEditing
            .bind(to: headerView.rx.editButtonState, bodyView.rx.isEditing)
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 600)) {
    SymptomSectionView()
}

// MARK: - Reactive

extension Reactive where Base: SymptomSectionView {
    
    var reloadBinder: Binder<Void> {
        Binder(base) { $0.bodyView.rx.reloadBinder.onNext($1) }
    }
    
    var itemToRemove: Observable<EditButtonCellModel> {
        base.bodyView.rx.itemToRemove
    }
    
    var addButtonTapEvent: Observable<Void> {
        base.headerView.rx.addButtonTapEvent
    }
}
