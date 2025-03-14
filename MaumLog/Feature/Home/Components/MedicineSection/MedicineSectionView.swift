//
//  MedicineSectionView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class MedicineSectionView: UIView {

    // MARK: Properties
    
    private let medicineSectionVM = MedicineSectionVM()
    private let bag = DisposeBag()
    
    // MARK: Interface
    
    private let itemToRemove = PublishSubject<EditButtonCellModel>()
    
    // MARK: Components
    
    private let sectionView = SectionView()
    fileprivate let headerView = SectionHeaderView("복용 중인 약")
    fileprivate let bodyView = MedicineSectionBodyView()
    
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
        let input = MedicineSectionVM.Input(
            editButtonTapEvent: headerView.rx.editButtonTapEvent
        )
        let output = medicineSectionVM.transform(input: input)
        
        // 편집 상태 바인딩
        output.isEditing
            .bind(to: headerView.rx.editButtonState, bodyView.rx.isEditing)
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 600)) {
    MedicineSectionView()
}

// MARK: - Reactive

extension Reactive where Base: MedicineSectionView {
    
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
