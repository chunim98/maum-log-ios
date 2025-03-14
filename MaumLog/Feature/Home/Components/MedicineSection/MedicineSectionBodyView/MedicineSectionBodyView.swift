//
//  MedicineSectionBodyView.swift
//  MaumLog
//
//  Created by 신정욱 on 3/11/25.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

final class MedicineSectionBodyView: UIView {

    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource
    
    // MARK: Properties
    
    private let medicineSectionBodyVM = MedicineSectionBodyVM()
    private let bag = DisposeBag()
    private let once = OnlyOnce()
    
    // MARK: Interface
    
    fileprivate let isEditing = PublishSubject<Bool>()
    fileprivate let reloadEvent = PublishSubject<Void>()
    fileprivate let itemToRemove = PublishSubject<EditButtonCellModel>()
    
    // MARK: Components
    
    private let collectionViewVStack = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = .init(edges: 10)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.backgroundColor = .chuWhite
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()

    fileprivate let medicineCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(CapsuleCell.self, forCellWithReuseIdentifier: CapsuleCell.identifier)
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.layer.cornerRadius = 15
        cv.clipsToBounds = true
        return cv
    }()
    
    fileprivate let emptyView = EmptyView(text: "복용 중인 약이 있다면 등록해 주세요.", textSize: 14)
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
        setBinding()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        once.excute { setCVLayout() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout
    
    private func setAutoLayout() {
        self.addSubview(collectionViewVStack)
        collectionViewVStack.addArrangedSubview(medicineCV)
        
        collectionViewVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func setCVLayout() {
        self.layoutIfNeeded()
        medicineCV.setMultilineLayout(spacing: 10, itemCount: 2, itemHeight: 30)
        let height = medicineCV.collectionViewLayout.collectionViewContentSize.height
        medicineCV.snp.makeConstraints { $0.height.equalTo(max(30, height)) }
    }
    
    // MARK: Binding
    
    private func setBinding() {
        let input = MedicineSectionBodyVM.Input(
            isEditing: isEditing.asObservable(),
            reloadEvent: reloadEvent.asObservable(),
            itemToRemove: medicineCV.rx.modelSelected(EditButtonCellModel.self).asObservable()
        )
        let output = medicineSectionBodyVM.transform(input)
        
        // 컬렉션 뷰 데이터 바인딩
        output.medicineSectionDataArr
            .bind(to: medicineCV.rx.items(
                dataSource: getCapsuleCellDataSource(MedicineSectionData.self)
            ))
            .disposed(by: bag)
        
        // 리로드 요청 시, 컬렉션 뷰 레이아웃 업데이트
        output.reloadEvent
            .bind(to: self.rx.updateCVHeightBinder)
            .disposed(by: bag)
        
        // 셀 데이터가 비어있으면, 대체 화면 표시
        output.isDataEmpty
            .bind(to: self.rx.cvBackgroundView)
            .disposed(by: bag)
        
        // 편집 상태일 때, 삭제할 아이템 전달
        output.itemToRemove
            .bind(to: itemToRemove)
            .disposed(by: bag)
    }
    
    // MARK: Rx Data Sources
    
    private func getCapsuleCellDataSource<T: AnimatableSectionModelType>(
        _: T.Type
    ) -> DataSource<T> where T.Item: CapsuleCellModel {
        
        /// CapsuleCellModel을 사용하는 모든 컬렉션뷰들과 바인딩
        /// 이름 없는 파라미터는 컴파일러에게 T가 무슨 타입인지 알려주는 용도
        /// CapsuleCellModel을 만족하는 타입만 섹션 데이터의 아이템으로 쓸 수 있음
        
        let animeConfig = AnimationConfiguration(
            insertAnimation: .fade,
            reloadAnimation: .fade,
            deleteAnimation: .fade
        )
        
        return DataSource<T>(
            animationConfiguration: animeConfig
        ) { _, collectionView, indexPath, data in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CapsuleCell.identifier,
                for: indexPath
            ) as? CapsuleCell
            else { return UICollectionViewCell() }
            cell.configure(data)
            return cell
        }
    }
}

#Preview {
    MedicineSectionBodyView()
}

// MARK: - Reactive

extension Reactive where Base: MedicineSectionBodyView {
    
    fileprivate var updateCVHeightBinder: Binder<Void> {
        Binder(base) { base, _ in
            base.layoutIfNeeded()
            let height = base.medicineCV.collectionViewLayout.collectionViewContentSize.height
            
            UIView.animate(withDuration: 0.5) {
                base.medicineCV.snp.updateConstraints { $0.height.equalTo(max(30, height)) }
                base.layoutIfNeeded()
            }
        }
    }
    
    fileprivate var cvBackgroundView: Binder<Bool> {
        Binder(base) { $0.medicineCV.backgroundView = $1 ? $0.emptyView : .none }
    }
    
    var isEditing: Binder<Bool> {
        Binder(base) { $0.isEditing.onNext($1) }
    }
    
    var reloadBinder: Binder<Void> {
        Binder(base) { $0.reloadEvent.onNext($1) }
    }
    
    var itemToRemove: Observable<EditButtonCellModel> {
        base.itemToRemove.asObservable()
    }
}
