//
//  SymptomSectionBodyView.swift
//  MaumLog
//
//  Created by 신정욱 on 3/10/25.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

final class SymptomSectionBodyView: UIView {

    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource
    
    // MARK: Properties
    
    private let symptomSectionBodyVM = SymptomSectionBodyVM()
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
    
    private let negativeTitleLabel = CircleAttachedLabel("부작용", .chuBadRate)
    private let otherTitleLabel = CircleAttachedLabel("기타 증상", .chuOtherRate)

    fileprivate let negativeCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(CapsuleCell.self, forCellWithReuseIdentifier: CapsuleCell.identifier)
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.layer.cornerRadius = 15
        cv.clipsToBounds = true
        return cv
    }()
    
    fileprivate let otherCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(CapsuleCell.self, forCellWithReuseIdentifier: CapsuleCell.identifier)
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.layer.cornerRadius = 15
        cv.clipsToBounds = true
        return cv
    }()
    
    fileprivate let negativeEmptyView = EmptyView(text: "아직 등록된 부작용이 없는 것 같아요.", textSize: 14)
    fileprivate let otherEmptyView = EmptyView(text: "아직 등록된 증상이 없는 것 같아요.", textSize: 14)
    
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
        collectionViewVStack.addArrangedSubview(negativeTitleLabel)
        collectionViewVStack.addArrangedSubview(negativeCV)
        collectionViewVStack.addArrangedSubview(otherTitleLabel)
        collectionViewVStack.addArrangedSubview(otherCV)
        
        collectionViewVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func setCVLayout() {
        self.layoutIfNeeded()
        
        // 플로우 레이아웃 구성
        negativeCV.setMultilineLayout(spacing: 10, itemCount: 3, itemHeight: 50)
        otherCV.setMultilineLayout(spacing: 10, itemCount: 3, itemHeight: 50)

        // 현재 컬렉션 뷰 안에 있는 열 높이 가져오기
        let negativeHeight = negativeCV.collectionViewLayout.collectionViewContentSize.height
        let otherHeight = otherCV.collectionViewLayout.collectionViewContentSize.height
        
        // 레이아웃 설정
        negativeCV.snp.makeConstraints { $0.height.equalTo(max(50, negativeHeight)) }
        otherCV.snp.makeConstraints { $0.height.equalTo(max(50, otherHeight)) }
    }
    
    // MARK: Binding
    
    private func setBinding() {
        let selectedModel = Observable.merge(
            negativeCV.rx.modelSelected(EditButtonCellModel.self).asObservable(),
            otherCV.rx.modelSelected(EditButtonCellModel.self).asObservable()
        )
        
        let input = SymptomSectionBodyVM.Input(
            isEditing: isEditing.asObservable(),
            reloadEvent: reloadEvent.asObservable(),
            selectedModel: selectedModel
        )
        let output = symptomSectionBodyVM.transform(input)
        
        // 부작용 컬렉션 뷰 데이터 바인딩
        output.negativeSectionDataArr
            .bind(to: negativeCV.rx.items(
                dataSource: getCapsuleCellDataSource(SymptomSectionData.self)
            ))
            .disposed(by: bag)
        
        // 기타 증상 컬렉션 뷰 데이터 바인딩
        output.otherSectionDataArr
            .bind(to: otherCV.rx.items(
                dataSource: getCapsuleCellDataSource(SymptomSectionData.self)
            ))
            .disposed(by: bag)
        
        // 리로드 요청 시, 컬렉션 뷰 레이아웃 업데이트
        output.reloadEvent
            .bind(to: self.rx.updateCVHeightBinder)
            .disposed(by: bag)
        
        // 셀 데이터가 비어있으면, 대체 화면 표시
        output.isNegativeDataEmpty
            .bind(to: self.rx.negativeCVBackgroundView)
            .disposed(by: bag)
        
        // 셀 데이터가 비어있으면, 대체 화면 표시
        output.isOtherDataEmpty
            .bind(to: self.rx.otherCVBackgroundView)
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
    SymptomSectionBodyView()
}

// MARK: - Reactive

extension Reactive where Base: SymptomSectionBodyView {
    
    fileprivate var updateCVHeightBinder: Binder<Void> {
        Binder(base) { base, _ in
            base.layoutIfNeeded()
            
            // 현재 컬렉션 뷰 안에 있는 열 높이 가져오기
            let negativeHeight = base.negativeCV
                .collectionViewLayout.collectionViewContentSize.height
            let otherHeight = base.otherCV
                .collectionViewLayout.collectionViewContentSize.height
            
            // 레이아웃 업데이트
            UIView.animate(withDuration: 0.5) {
                base.negativeCV.snp.updateConstraints {
                    $0.height.equalTo(max(50, negativeHeight))
                }
                base.otherCV.snp.updateConstraints {
                    $0.height.equalTo(max(50, otherHeight))
                }
                base.layoutIfNeeded()
            }
        }
    }
    
    fileprivate var negativeCVBackgroundView: Binder<Bool> {
        Binder(base) { $0.negativeCV.backgroundView = $1 ? $0.negativeEmptyView : .none }
    }
    
    fileprivate var otherCVBackgroundView: Binder<Bool> {
        Binder(base) { $0.otherCV.backgroundView = $1 ? $0.otherEmptyView : .none }
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
