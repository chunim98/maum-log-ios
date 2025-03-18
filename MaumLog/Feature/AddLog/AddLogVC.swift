//
//  AddVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/5/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AddLogVC: UIViewController {
    
    private let addLogVM = AddLogVM()
    private let bag = DisposeBag()
    weak var coordinator: AddLogCoordinator?
    var dismissTask: (() -> Void)?
    
    private let addPendingLog = PublishSubject<SymptomCardData>()
    private let removePendingLogByIndex = PublishSubject<Int>()
    private let updateRate = PublishSubject<(index: Int, rate: Int)>()
    
    // MARK: - Components
    let titleBackground = {
        let view = UIView()
        view.backgroundColor = .chuIvory
        return view
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "새 기록 추가")
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .chuBlack
        label.textAlignment = .center
        return label
    }()
    
    let closeButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "x")?
            .resizeImage(newWidth: 22)
            .withRenderingMode(.alwaysTemplate)
        config.baseForegroundColor = .chuBlack
        return UIButton(configuration: config)
    }()
    
    let pendingLogTV = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(PendingLogCell.self, forCellReuseIdentifier: PendingLogCell.identifier)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.showsVerticalScrollIndicator = false
        tv.clipsToBounds = false
        return tv
    }()
    
    let pendingLogEmptyView = {
        let view = EmptyView(
            text: String(localized: "증상 버튼을 눌러 기록을 추가할 수 있어요."),
            textSize: 14,
            image: UIImage(named: "addList"),
            spacing: 20)
        
        view.label.textColor = .lightGray
        return view
    }()
    
    let bottomSVBackground = OutlinedView(strokeWidth: .chuStrokeWidth)
    
    let bottomVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    let negativeVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
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
        cv.register(LoggableCapsuleCell.self, forCellWithReuseIdentifier: LoggableCapsuleCell.identifier)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.clipsToBounds = true
        cv.layer.cornerRadius = 25
        cv.setSinglelineLayout(spacing: 5, width: 100, height: 50)
        return cv
    }()
    
    let negativeEmptyView = EmptyView(text: String(localized: "아직 등록된 부작용이 없는 것 같아요."), textSize: 14)
    
    let otherVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
        return sv
    }()
    
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
        cv.register(LoggableCapsuleCell.self, forCellWithReuseIdentifier: LoggableCapsuleCell.identifier)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.clipsToBounds = true
        cv.layer.cornerRadius = 25
        cv.setSinglelineLayout(spacing: 5, width: 100, height: 50)
        return cv
    }()
    
    let otherEmptyView = EmptyView(text: String(localized: "아직 등록된 증상이 없는 것 같아요."), textSize: 14)

    let confirmButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.title = String(localized: "추가")
        config.baseBackgroundColor = .chuBlack
        config.baseForegroundColor = .chuWhite
        let button =  UIButton(configuration: config)
        button.isEnabled = false
        return button
    }()
    

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        
        setAutoLayout()
        setBinding()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.finish()
    }
    
    // MARK: - Layout
    func setAutoLayout() {
        view.addSubview(pendingLogTV)
        view.addSubview(titleBackground)
        view.addSubview(bottomSVBackground)
        titleBackground.addSubview(titleLabel)
        titleBackground.addSubview(closeButton)
        bottomSVBackground.addSubview(bottomVStack)
        bottomVStack.addArrangedSubview(negativeVStack)
        bottomVStack.addArrangedSubview(otherVStack)
        bottomVStack.addArrangedSubview(confirmButton)
        negativeVStack.addArrangedSubview(negativeTitleLabel)
        negativeVStack.addArrangedSubview(negativeCV)
        otherVStack.addArrangedSubview(otherTitleLabel)
        otherVStack.addArrangedSubview(otherCV)

        pendingLogTV.snp.makeConstraints {
            $0.top.equalTo(titleBackground.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(bottomSVBackground.snp.top)
        }
        titleBackground.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: .chuSpace, bottom: 10, right: .chuSpace))
        }
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        bottomSVBackground.snp.makeConstraints {
            // 배경은 세이프 에어리어 밑까지 채워야 함
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        bottomVStack.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(15)
            // 스택뷰는 세이프 에어리어까지만
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        negativeCV.snp.makeConstraints { $0.height.equalTo(50) }
        otherCV.snp.makeConstraints { $0.height.equalTo(50) }
        confirmButton.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    // MARK: - Binding
    func setBinding() {
        let input = AddLogVM.Input(
            addPendingLog: addPendingLog.asObservable(),
            removePendingLogByIndex: removePendingLogByIndex.asObservable(),
            updateRate: updateRate.asObservable(),
            tappedConfirmButton: confirmButton.rx.tap.asObservable(),
            tappedCloseButton: closeButton.rx.tap.asObservable())

        let output = addLogVM.transform(input)
        
        output.negativeData
            .bind(to: negativeCV.rx.items(cellIdentifier: LoggableCapsuleCell.identifier, cellType: LoggableCapsuleCell.self)) { index, item, cell in
                cell.configure(item: item)
                cell.addTask = { [weak self] in
                    let cardData = SymptomCardData(name: item.name, hex: item.hex, isNegative: item.isNegative, rate: 3)
                    self?.addPendingLog.onNext(cardData)
                }
            }
            .disposed(by: bag)
        
        output.otherData
            .bind(to: otherCV.rx.items(cellIdentifier: LoggableCapsuleCell.identifier, cellType: LoggableCapsuleCell.self)) { index, item, cell in
                cell.configure(item: item)
                cell.addTask = { [weak self] in
                    let cardData = SymptomCardData(name: item.name, hex: item.hex, isNegative: item.isNegative, rate: 3)
                    self?.addPendingLog.onNext(cardData)
                }
            }
            .disposed(by: bag)

        // 증상 테이블에 아직 등록된 증상이 없다면 표시
        output.isSymptomDataEmpty
            .bind(with: self) { owner, isSymptomDataEmpty in
                let (isNegativeEmpty, isOtherEmpty) = isSymptomDataEmpty
                
                if isNegativeEmpty {
                    owner.negativeCV.backgroundView = owner.negativeEmptyView
                } else {
                    owner.negativeCV.backgroundView = .none
                }
                
                if isOtherEmpty {
                    owner.otherCV.backgroundView = owner.otherEmptyView
                } else {
                    owner.otherCV.backgroundView = .none
                }
            }
            .disposed(by: bag)
        
        
        output.pendingLogData
            .bind(to: pendingLogTV.rx.items(cellIdentifier: PendingLogCell.identifier, cellType: PendingLogCell.self)) { [weak self] index, item, cell in
                guard let self else { return }
                cell.configure(item: item)
                cell.removeCellTask = { self.removePendingLogByIndex.onNext(index) }
                cell.sliderValueChangedTask = { self.updateRate.onNext( (index: index, rate: Int(cell.slider.value)) ) }
            }
            .disposed(by: bag)
        
        
        // 테이블에 아무것도 없을 때 추가버튼 비활성화
        output.isEnabledConfirmButton
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: bag)
        
        
        // 테이블에 뭐라도 있다면 모달 제스처로 닫기 비활성화
        output.isEnabledModalGesture
            .bind(with: self) { owner, isEnabledModalGesture in
                owner.isModalInPresentation = isEnabledModalGesture
            }
            .disposed(by: bag)
        
        
        // 추가된 임시 기록이 없으면 안내문구 표시
        output.isPendingLogEmpty
            .bind(with: self) { owner, isPendingLogEmpty in
                if isPendingLogEmpty {
                    owner.pendingLogTV.backgroundView = owner.pendingLogEmptyView
                } else {
                    owner.pendingLogTV.backgroundView = .none
                }
            }
            .disposed(by: bag)
        
        // 리스트의 계류 로그 메인 저장소에 저장하고 화면 닫기
        output.confirmWithDismiss
            .bind(with: self) { owner, _ in
                owner.dismissTask?()
                owner.dismiss(animated: true)
            }
            .disposed(by: bag)
        
        // 그냥 화면 닫기
        output.justDismiss
            .bind(with: self) { owner, _ in owner.dismiss(animated: true) }
            .disposed(by: bag)
    }
}



#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    AddLogVC()
}
