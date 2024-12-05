//
//  SymptomSectionView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/18/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class SymptomSectionView: UIView {
    typealias SectionDataSource = RxCollectionViewSectionedAnimatedDataSource

    private let symptomSectionVM = SymptomSectionVM()
    private let bag = DisposeBag()
    
    private let itemToRemove = PublishSubject<EditButtonCellModel>()
    let reloadCV = PublishSubject<Void>()
    let presentRemoveSymptomAlert = PublishSubject<EditButtonCellModel>()
    let goAddSymptom = PublishSubject<Void>()
    
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
        sv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sv.directionalLayoutMargins = .init(top: 5, leading: 10, bottom: 5, trailing: 0)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layer.cornerRadius = 15
        sv.clipsToBounds = true
        sv.backgroundColor = .chuWhite
        return sv
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "등록된 증상")
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .chuBlack
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
        sv.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        sv.directionalLayoutMargins = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layer.cornerRadius = 15
        sv.clipsToBounds = true
        sv.backgroundColor = .chuWhite
        return sv
    }()

    let negativeTitleLabel = {
        let label = UILabel()
        
        // 볼드체 설정
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.chuBlack ]
        
        // 텍스트 뒤에 이미지 붙이기
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "circle.fill")? // 옵셔널 체이닝임 놀라지 말 것
            .resizeImage(newWidth: 12)
            .withTintColor(.chuBadRate)
        
        // 텍스트 설정
        let attributedString = NSMutableAttributedString(string: String(localized: "부작용 "), attributes: attributes)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        
        label.attributedText = attributedString
        return label
    }()

    let negativeCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.register(CapsuleCell.self, forCellWithReuseIdentifier: CapsuleCell.identifier)// 셀의 등록과정 (스토리보드 사용시에는 스토리보드에서 자동등록)
        cv.showsVerticalScrollIndicator = false // 스크롤 바 숨기기
        cv.backgroundColor = .clear
        cv.clipsToBounds = true
        cv.layer.cornerRadius = 25
        return cv
    }()
    
    let negativeEmptyView = EmptyView(text: String(localized: "아직 등록된 부작용이 없는 것 같아요."), textSize: 14)
    
    let otherTitleLabel = {
        let label = UILabel()
        
        // 볼드체 설정
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.chuBlack ]
        
        // 텍스트 뒤에 이미지 붙이기
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "circle.fill")? // 옵셔널 체이닝임 놀라지 말 것
            .resizeImage(newWidth: 12)
            .withTintColor(.chuOtherRate)
        
        // 텍스트 설정
        let attributedString = NSMutableAttributedString(string: String(localized: "기타 증상 "), attributes: attributes)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        
        label.attributedText = attributedString
        return label
    }()
    
    let otherCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.register(CapsuleCell.self, forCellWithReuseIdentifier: CapsuleCell.identifier) // 셀의 등록과정 (스토리보드 사용시에는 스토리보드에서 자동등록)
        cv.showsVerticalScrollIndicator = false // 스크롤 바 숨기기
        cv.backgroundColor = .clear
        cv.clipsToBounds = true
        cv.layer.cornerRadius = 25
        return cv
    }()
    
    let otherEmptyView = EmptyView(text: String(localized: "아직 등록된 증상이 없는 것 같아요."), textSize: 14)

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
        
        collectionViewVStack.addArrangedSubview(negativeTitleLabel)
        collectionViewVStack.addArrangedSubview(negativeCV)
        collectionViewVStack.addArrangedSubview(otherTitleLabel)
        collectionViewVStack.addArrangedSubview(otherCV)

        titleLabel.setContentHuggingPriority(.init(249), for: .horizontal)

        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // 뷰컨에서 호출
    func setCVLayout() {
        // flowLayout설정 (익스텐션)
        negativeCV.setMultilineLayout(spacing: 10, itemCount: 3, itemHeight: 50)
        otherCV.setMultilineLayout(spacing: 10, itemCount: 3, itemHeight: 50)

        // 현재 컬렉션 뷰 안에 있는 열 높이 가져오기
        let negativeHeight = negativeCV.collectionViewLayout.collectionViewContentSize.height
        let otherHeight = otherCV.collectionViewLayout.collectionViewContentSize.height

        // 레이아웃 설정
        negativeCV.snp.makeConstraints {
            if negativeHeight <= 50 {
                $0.height.equalTo(50)
            } else {
                $0.height.equalTo(negativeHeight)
            }
        }
        otherCV.snp.makeConstraints {
            if otherHeight <= 50 {
                $0.height.equalTo(50)
            } else {
                $0.height.equalTo(otherHeight)
            }
        }
    }
    
    // MARK: - Binding
    private func setBinding() {
        let input = SymptomSectionVM.Input(
            tappedAddButton: addButton.rx.tap.asObservable(),
            tappedEditButton: editButton.rx.tap.asObservable(),
            reloadCV: reloadCV.asObservable(),
            itemToRemove: itemToRemove)
        
        let output = symptomSectionVM.transform(input: input)
        
        // 컬렉션 뷰 바인딩, 부작용
        output.negativeCellDataArr
            .bind(to: negativeCV.rx.items(dataSource: bindingCapsuleCellCV(SymptomSectionData.self)))
            .disposed(by: bag)
        
        // 컬렉션 뷰 바인딩, 기타증상
        output.otherCellDataArr
            .bind(to: otherCV.rx.items(dataSource: bindingCapsuleCellCV(SymptomSectionData.self)))
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
            .bind(with: self, onNext: { owner, isEditMode in
                owner.updateEditButton(isEditMode)
            })
            .disposed(by: bag)
        
        
        // 증상이 등록된 게 없으면 이미지 표시
        output.isDataEmpty
            .bind(with: self, onNext: { owner, isDataEmpty in
                let (isNegativeEmpty, isOtherEmpty) = isDataEmpty
                owner.setCVBackground(isNegativeEmpty, isOtherEmpty)
            })
            .disposed(by: bag)
        
        // 삭제 얼럿을 띄우기
        output.presentRemoveAlert
            .bind(to: presentRemoveSymptomAlert)
            .disposed(by: bag)
        
        // 증상 추가 모달 띄우기
        output.goAddSymptom
            .bind(to: goAddSymptom)
            .disposed(by: bag)
    }

    // MARK: - Methods
    private func updateCVHeight() {
        // 최신 콘텐츠 높이 가져오기
        layoutIfNeeded()
        
        // 현재 컬렉션 뷰 안에 있는 열 높이 가져오기
        let negativeHeight = negativeCV.collectionViewLayout.collectionViewContentSize.height
        let otherHeight = otherCV.collectionViewLayout.collectionViewContentSize.height
        
        // 레이아웃 업데이트
        negativeCV.snp.updateConstraints {
            if negativeHeight <= 50 {
                $0.height.equalTo(50)
            } else {
                $0.height.equalTo(negativeHeight)
            }
        }
        otherCV.snp.updateConstraints {
            if otherHeight <= 50 {
                $0.height.equalTo(50)
            } else {
                $0.height.equalTo(otherHeight)
            }
        }
    }
    
    private func updateEditButton(_ isEditMode: Bool) {
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

    private func setCVBackground(_ isNegativeEmpty: Bool, _ isOtherEmpty: Bool) {
        if isNegativeEmpty {
            negativeCV.backgroundView = negativeEmptyView
        } else {
            negativeCV.backgroundView = .none
        }
        
        if isOtherEmpty {
            otherCV.backgroundView = otherEmptyView
        } else {
            otherCV.backgroundView = .none
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
            
            cell.configure(item: item)
            
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
    SymptomSectionView()
}
