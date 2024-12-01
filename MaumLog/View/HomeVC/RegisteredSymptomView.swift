//
//  RegisteredSymptomView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/18/24.
//

import UIKit
import SnapKit

final class RegisteredSymptomView: UIView {
    
    /* 컬렉션 뷰를 한번만 초기화 하기 위해 필요한 변수
     콘텐츠 높이를 받아와서 제약을 걸기 때문에 layoutSubviews에서
     초기화 시켜줘야 함, 근데 layoutIfNeeded()할 때마다
     매번 제약을 걸어주려고 하면 make와 update가 충돌이 남 */
    private var isSetCVLayout = false
    
    //MARK: - 컴포넌트
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

    //MARK: - 라이프 사이클
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.snp.makeConstraints { make in make.width.equalTo(400) }
        setAutoLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCVLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 오토레이아웃
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
        // 제약은 최초로 한번만 걸어주게 하기
        guard !(isSetCVLayout) else { return }
        // 서브뷰의 레이아웃이 완전히 결정되지 않는 경우에 대비해 레이아웃 업데이트
        layoutIfNeeded()

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
            }else{
                make.height.equalTo(negativeHeight)
            }
        }
        otherCV.snp.makeConstraints { make in
            if otherHeight <= 50 {
                make.height.equalTo(50)
            }else{
                make.height.equalTo(otherHeight)
            }
        }
        
        // 제약은 최초로 한번만 걸어주게 하기
        isSetCVLayout = true
    }
    
    
    // 뷰컨에서 UI.animate()에 파라미터로 던져짐
    func updateCVHeight() {
        // 최신 콘텐츠 높이 가져오기
        layoutIfNeeded()
        // 현재 컬렉션 뷰 안에 있는 열 높이 가져오기
        let negativeHeight = negativeCV.collectionViewLayout.collectionViewContentSize.height
        let otherHeight = otherCV.collectionViewLayout.collectionViewContentSize.height

        
        // 레이아웃 업데이트
        negativeCV.snp.updateConstraints { make in
            if negativeHeight <= 50 {
                make.height.equalTo(50)
            }else{
                make.height.equalTo(negativeHeight)
            }
        }
        otherCV.snp.updateConstraints { make in
            if otherHeight <= 50 {
                make.height.equalTo(50)
            }else{
                make.height.equalTo(otherHeight)
            }
        }
    }
    
    
    func updateEditButton(isEditMode: Bool) {
        if isEditMode {
            editButton.configuration?.title = String(localized: "완료")
            editButton.configuration?.baseForegroundColor = .chuWhite
            editButton.configuration?.baseBackgroundColor = .chuTint
        }else{
            editButton.configuration?.title = String(localized: "편집")
            editButton.configuration?.baseForegroundColor = .chuBlack
            editButton.configuration?.baseBackgroundColor = .clear
        }
    }
    
    
    func setCVBackground(isNegativeEmpty: Bool, isOtherEmpty: Bool) {
        layoutIfNeeded()
        
        if isNegativeEmpty {
            negativeCV.backgroundView = negativeEmptyView
        }else{
            negativeCV.backgroundView = .none
        }
        
        if isOtherEmpty {
            otherCV.backgroundView = otherEmptyView
        }else{
            otherCV.backgroundView = .none
        }
    }

    
}

#Preview(traits: .fixedLayout(width: 400, height: 600)) {
    RegisteredSymptomView()
}
