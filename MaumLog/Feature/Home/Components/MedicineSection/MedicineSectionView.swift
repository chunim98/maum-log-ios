//
//  MedicineSectionView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class MedicineSectionView: UIView {
    typealias SectionDataSource = RxCollectionViewSectionedAnimatedDataSource
    
    private let medicineSubVM = MedicineSectionVM()
    private let bag = DisposeBag()
    
    private let itemToRemove = PublishSubject<EditButtonCellModel>()
    let reloadCV = PublishSubject<Void>()
    let presentRemoveMedicineAlert = PublishSubject<EditButtonCellModel>()
    let goAddMedicine = PublishSubject<Void>()

    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 1
        return sv
    }()

    let titleHStack = {
        let sv = UIStackView()
        sv.spacing = 10
        sv.backgroundColor = .chuWhite
        sv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 15
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 5, leading: 10, bottom: 5, trailing: 0)
        return sv
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "복용 중인 약")
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .chuBlack
        label.backgroundColor = .clear
        return label
    }()
    
    let editButton = {
        var config = UIButton.Configuration.filled()
        config.title = String(localized: "편집") // 임시
        config.baseForegroundColor = .chuBlack // 임시
        config.baseBackgroundColor = .clear // 임시
        config.cornerStyle = .capsule
        return UIButton(configuration: config)
    }()
    
    let addButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "plus")?
            .resizeImage(newWidth: 18)
            .withRenderingMode(.alwaysTemplate)
        config.baseForegroundColor = .chuBlack
        return UIButton(configuration: config)
    }()
    
    let collectionViewVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.backgroundColor = .chuWhite
        sv.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 15
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        return sv
    }()
    
    let collectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.register(CapsuleCell.self, forCellWithReuseIdentifier: CapsuleCell.identifier)// 셀의 등록과정 (스토리보드 사용시에는 스토리보드에서 자동등록)
        cv.showsVerticalScrollIndicator = false // 스크롤 바 숨기기
        cv.backgroundColor = .clear
        cv.clipsToBounds = true
        cv.layer.cornerRadius = 15
        return cv
    }()
    
    let emptyView = EmptyView(text: String(localized: "복용 중인 약이 있다면 등록해 주세요."), textSize: 14)
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        self.addSubview(mainVStack)
        
        mainVStack.addArrangedSubview(titleHStack)
        mainVStack.addArrangedSubview(collectionViewVStack)
        
        titleHStack.addArrangedSubview(titleLabel)
        titleHStack.addArrangedSubview(editButton)
        titleHStack.addArrangedSubview(addButton)
        
        collectionViewVStack.addArrangedSubview(collectionView)
        
        titleLabel.setContentHuggingPriority(.init(249), for: .horizontal)
        
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func setCVLayout() {
        // flowLayout설정 (익스텐션)
        collectionView.setMultilineLayout(spacing: 10, itemCount: 2, itemHeight: 30)
        
        // 현재 컬렉션 뷰 안에 있는 열 높이 가져오기
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        
        // 레이아웃 설정
        collectionView.snp.makeConstraints { make in
            if height <= 30 {
                make.height.equalTo(30)
            }else{
                make.height.equalTo(height)
            }
        }
    }
    
    // MARK: - Binding
    private func setBinding() {
        let input = MedicineSectionVM.Input(
            tappedAddButton: addButton.rx.tap.asObservable(),
            tappedEditButton: editButton.rx.tap.asObservable(),
            reloadCV: reloadCV.asObservable(),
            itemToRemove: itemToRemove.asObservable())
        
        let output = medicineSubVM.transform(input)
        
        // 컬렉션 뷰 바인딩, 복용중인 약
        output.cellData
            .bind(to: collectionView.rx.items(dataSource: bindingCapsuleCellCV(MedicineSectionData.self)))
            .disposed(by: bag)
        
        // 컬렉션 뷰 레이아웃 재계산
        output.needUpdateCV
            .bind(with: self) { owner, _ in
                UIView.animate(withDuration: 0.5) {
                    owner.updateCVHeight()
                    owner.layoutIfNeeded()
                }
            }
            .disposed(by: bag)
        
        // 증상의 편집버튼을 누르면 버튼의 디자인이 바뀜
        output.isEditMode
            .bind(with: self) { owner, isEditMode in
                owner.updateEditButton(isEditMode: isEditMode)
            }
            .disposed(by: bag)

        // 약물이 등록된 게 없으면 이미지 표시
        output.isDataEmpty
            .bind(with: self) { owner, isDataEmpty in
                owner.setCVBackground(isDataEmpty)
            }
            .disposed(by: bag)
        
        output.presentRemoveMedicineAlert
            .bind(to: presentRemoveMedicineAlert)
            .disposed(by: bag)
        
        output.goAddMedicine
            .bind(to: goAddMedicine)
            .disposed(by: bag)
    }

    // MARK: - Methods
    private func updateCVHeight() {
        // 최신 콘텐츠 높이 가져오기
        layoutIfNeeded()
        // 현재 컬렉션 뷰 안에 있는 열 높이 가져오기
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        
        // 레이아웃 업데이트
        collectionView.snp.updateConstraints { make in
            if height <= 30 {
                make.height.equalTo(30)
            } else {
                make.height.equalTo(height)
            }
        }
    }
    
    private func updateEditButton(isEditMode: Bool) {
        if isEditMode {
            editButton.configuration?.title = String(localized: "완료")
            editButton.configuration?.baseForegroundColor = .chuWhite
            editButton.configuration?.baseBackgroundColor = .chuTint
        } else {
            editButton.configuration?.title = String(localized: "편집")
            editButton.configuration?.baseForegroundColor = .chuBlack
            editButton.configuration?.baseBackgroundColor = .clear
        }
    }
    
    private func setCVBackground(_ isEmpty: Bool) {
        layoutIfNeeded()
        
        if isEmpty {
            collectionView.backgroundView = emptyView
        } else {
            collectionView.backgroundView = .none
        }
    }

    private func bindingCapsuleCellCV<T: AnimatableSectionModelType>(_: T.Type) -> SectionDataSource<T> where T.Item: CapsuleCellModel {
        
        /// CapsuleCellModel을 사용하는 모든 컬렉션뷰들과 바인딩
        /// 이름 없는 파라미터는 컴파일러에게 T가 무슨 타입인지 알려주는 용도
        /// CapsuleCellModel을 따르는 타입만 섹션데이터의 아이템으로 쓸 수 있게
        
        let animatedDataSource = SectionDataSource<T> { [weak self] animatedDataSource, collectionView, indexPath, item in
            guard
                let self,
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CapsuleCell.identifier, for: indexPath) as? CapsuleCell
            else { return UICollectionViewCell() }
            
            cell.setAttributes(item: item)
            
            cell.itemToRemove
                .bind(to: self.itemToRemove)
                .disposed(by: bag)
            
            return cell
        }
        
        // 애니메이션 구성 (생성자에서 구현해도 되긴 함)
        animatedDataSource.animationConfiguration = .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade)
        return animatedDataSource
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 600)) {
    MedicineSectionView()
}
