//
//  RegisteredMedicineView.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import SnapKit

final class RegisteredMedicineView: UIView {
    
    private var isSetCVLayout = false
    
    // MARK: - 컴포넌트
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
    
    //MARK: - 라이프사이클
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    func setAutoLayout() {
        self.addSubview(overallSV)
        
        overallSV.addArrangedSubview(titleSV)
        overallSV.addArrangedSubview(collectionViewSV)
        
        titleSV.addArrangedSubview(titleLabel)
        titleSV.addArrangedSubview(editButton)
        titleSV.addArrangedSubview(addButton)
        
        collectionViewSV.addArrangedSubview(collectionView)
        
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
        
        // 제약은 최초로 한번만 걸어주게 하기
        isSetCVLayout = true
    }
    
    
    // 뷰컨에서 UI.animate()에 파라미터로 던져짐
    func updateCVHeight() {
        // 최신 콘텐츠 높이 가져오기
        layoutIfNeeded()
        // 현재 컬렉션 뷰 안에 있는 열 높이 가져오기
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        
        // 레이아웃 업데이트
        collectionView.snp.updateConstraints { make in
            if height <= 30 {
                make.height.equalTo(30)
            }else{
                make.height.equalTo(height)
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
    
    
    func setCVBackground(isEmpty: Bool) {
        layoutIfNeeded()
        
        if isEmpty {
            collectionView.backgroundView = emptyView
        }else{
            collectionView.backgroundView = .none
        }
    }


}

#Preview(traits: .fixedLayout(width: 400, height: 600)) {
    RegisteredMedicineView()
}
