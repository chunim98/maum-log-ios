//
//  RegisteredSymptomView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/18/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class RegisteredSymptomView2: UIView {
    private let addedSymptomSubVM = AddedSymptomSubVM2()
    private let bag = DisposeBag()
    private let once = OnlyOnce()
    
    let reloadCV = PublishSubject<Void>()
    
    // MARK: - Components
    let overallSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 1
        sv.distribution = .fill
        return sv
    }()

    let titleSV = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fill
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
        label.text = String(localized: "등록된 증상")
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
    
    let collectionViewSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.distribution = .fill
        sv.backgroundColor = .chuWhite
        sv.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 15
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
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
//        self.snp.makeConstraints { make in make.width.equalTo(400) }
        setAutoLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        once.excute {
            layoutIfNeeded()
            setCVLayout()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        self.addSubview(overallSV)
        
        overallSV.addArrangedSubview(titleSV)
        overallSV.addArrangedSubview(collectionViewSV)
        
        titleSV.addArrangedSubview(titleLabel)
        titleSV.addArrangedSubview(editButton)
        titleSV.addArrangedSubview(addButton)
        
        collectionViewSV.addArrangedSubview(negativeTitleLabel)
        collectionViewSV.addArrangedSubview(negativeCV)
        collectionViewSV.addArrangedSubview(otherTitleLabel)
        collectionViewSV.addArrangedSubview(otherCV)


        titleLabel.setContentHuggingPriority(.init(249), for: .horizontal)

        overallSV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
    
    private func setCVLayout() {
        // flowLayout설정 (익스텐션)
        negativeCV.setMultilineLayout(spacing: 10, itemCount: 3, itemHeight: 50)
        otherCV.setMultilineLayout(spacing: 10, itemCount: 3, itemHeight: 50)

        // 현재 컬렉션 뷰 안에 있는 열 높이 가져오기
        let negativeHeight = negativeCV.collectionViewLayout.collectionViewContentSize.height
        let otherHeight = otherCV.collectionViewLayout.collectionViewContentSize.height

        // 레이아웃 설정
        negativeCV.snp.makeConstraints { make in
            if negativeHeight <= 50 {
                make.height.equalTo(50)
            } else {
                make.height.equalTo(negativeHeight)
            }
        }
        otherCV.snp.makeConstraints { make in
            if otherHeight <= 50 {
                make.height.equalTo(50)
            } else {
                make.height.equalTo(otherHeight)
            }
        }
    }
    
    // MARK: - Binding
    private func setBinding() {
        let input = AddedSymptomSubVM2.Input(
            tappedAddButton: addButton.rx.tap.asObservable(),
            tappedEditButton: editButton.rx.tap.asObservable(),
            reloadCV: reloadCV.asObservable())
        
        let output = addedSymptomSubVM.transform(input: input)
        
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
        
    }

    private func updateCVHeight() {
        // 최신 콘텐츠 높이 가져오기
        layoutIfNeeded()
        
        // 현재 컬렉션 뷰 안에 있는 열 높이 가져오기
        let negativeHeight = negativeCV.collectionViewLayout.collectionViewContentSize.height
        let otherHeight = otherCV.collectionViewLayout.collectionViewContentSize.height
        
        // 레이아웃 업데이트
        negativeCV.snp.updateConstraints { make in
            if negativeHeight <= 50 {
                make.height.equalTo(50)
            } else {
                make.height.equalTo(negativeHeight)
            }
        }
        otherCV.snp.updateConstraints { make in
            if otherHeight <= 50 {
                make.height.equalTo(50)
            } else {
                make.height.equalTo(otherHeight)
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
        layoutIfNeeded()
        
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


}

extension RegisteredSymptomView2: EditButtonCellDelegate {
    // CapsuleCellModel을 사용하는 모든 컬렉션뷰들과 바인딩
    private func bindingCapsuleCellCV<T: AnimatableSectionModelType>( // 제네릭으로 타입 결정 지연
        _: T.Type // 컴파일러에게 T가 무슨 타입인지 알려주는 용도
    ) -> RxCollectionViewSectionedAnimatedDataSource<T> where T.Item: CapsuleCellModel { // CapsuleCellModel을 따르는 타입만 섹션데이터의 아이템으로 쓸 수 있게
        
        let animatedDataSource = RxCollectionViewSectionedAnimatedDataSource<T> { [weak self] animatedDataSource, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CapsuleCell.identifier, for: indexPath) as? CapsuleCell
            guard let cell, let self else { return UICollectionViewCell() }
            cell.setAttributes(item: item)
            cell.delegate = self
            return cell
        }
        
        // 애니메이션 구성 (생성자에서 구현해도 되긴 함)
        animatedDataSource.animationConfiguration = .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade)
        return animatedDataSource
    }
    
    func removeTask(item: any EditButtonCellModel) {
//        switch item {
//        case let item as SymptomData:
//            presentAlert( // 얼럿 띄우기
//                title: String(localized: "알림"),
//                message: String(localized: "\"\(item.name)\" 증상을 목록에서 삭제할까요?"),
//                acceptTitle: String(localized: "삭제"),
//                acceptTask: { [weak self] in
//                    SymptomDataManager.shared.delete(target: item) // 등록한 증상 삭제
//                    self?.reloadCV.onNext(()) // 컬렉션 뷰 리로드 이벤트 전송
//                })
//            
//        case let item as MedicineData:
//            presentAlert( // 얼럿 띄우기
//                title: String(localized: "알림"),
//                message: String(localized: "\"\(item.name)\" 을 목록에서 삭제할까요?"),
//                acceptTitle: String(localized: "삭제"),
//                acceptTask: { [weak self] in
//                    MedicineDataManager.shared.delete(target: item) // 등록한 증상 삭제
//                    self?.reloadCV.onNext(()) // 컬렉션 뷰 리로드 이벤트 전송
//                    UIView.animate(withDuration: 0.5) {
//                        self?.medicineView.updateCVHeight() // 컬렉션 뷰 레이아웃 재계산
//                        self?.view.layoutIfNeeded()
//                    }
//                })
//            
//        default:
//            print("오류발생", #function)
//            return
//        }
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 600)) {
    RegisteredSymptomView()
}
