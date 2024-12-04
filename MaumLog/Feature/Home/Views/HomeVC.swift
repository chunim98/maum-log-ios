//
//  ViewController.swift
//  MaumLog
//
//  Created by 신정욱 on 7/26/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class HomeVC: UIViewController {
    
    private let homeVM = HomeVM()
    private let bag = DisposeBag()
    private let once = OnlyOnce()
    
    // MARK: - 컴포넌트
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "대시보드")
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .chuBlack
        return label
    }()
    
    let goSettingsBarButton = {
        let image = UIImage(named: "gear")?.resizeImage(newWidth: 24)
        let barButton = UIBarButtonItem(image: image, style: .plain, target: .none, action: .none)
        barButton.tintColor = .chuBlack
        return barButton
    }()
    
    let scrollview = {
        let view = UIScrollView()
        view.refreshControl = UIRefreshControl()
        view.refreshControl?.attributedTitle = NSAttributedString(
            string: String(localized: "당겨서 새로고침"),
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        view.clipsToBounds = false
        view.backgroundColor = .chuIvory
        return view
    }()
    
    let contentView = {
        let view = UIView()
        view.clipsToBounds = false
        view.backgroundColor = .chuIvory
        return view
    }()
    
    let overallSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 15
        return sv
    }()
    
    let symptomView = RegisteredSymptomView()
    
    let medicineView = RegisteredMedicineView()

    let averageCalendarView = AverageRateCalendarView()
    
    // MARK: - 라이프 사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        averageCalendarView.calendarView.delegate = self
        
        setNavigationBar(
            leftBarButtonItems: [UIBarButtonItem(customView: titleLabel)],
            rightBarButtonItems: [goSettingsBarButton])
        setAutoLayout()
        setBinding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        once.excute {
            symptomView.setCVLayout()
        }
    }
    
    // MARK: - 오토레이아웃
    func setAutoLayout() {
        view.addSubview(scrollview)
        
        scrollview.addSubview(contentView)
        
        contentView.addSubview(overallSV)
        
        overallSV.addArrangedSubview(symptomView)
        overallSV.addArrangedSubview(medicineView)
        overallSV.addArrangedSubview(averageCalendarView)
        
        
        scrollview.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalToSuperview()
        }
        overallSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 15, bottom: 50, right: 15))
        }
    }
    
    //MARK: - 바인딩
    func setBinding() {
        
        // 스크롤 뷰를 잡아당겼을 때 리프레쉬가 필요하다는 메시지 전달
        let startRefreshing = scrollview.refreshControl?
            .rx.controlEvent(.valueChanged).asObservable() ?? .empty()

        let input = HomeVM.Input(
            tappedGoSettingsButton: goSettingsBarButton.rx.tap.asObservable(),
            startRefreshing: startRefreshing,
            goAddSymptom: symptomView.goAddSymptom.asObservable(),
            presentRemoveAlert: symptomView.presentRemoveAlert.asObservable())
        
        // MARK: - Output
        let output = homeVM.transform(input)
        
        // 설정 화면 이동
        output.goSettings
            .bind(with: self) { owner, _ in
                let vc = SettingsVC()
                vc.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: bag)
        
        // 스크롤 뷰 리프레쉬 종료
        output.endRefreshing
            .bind(with: self) { owner, _ in
                owner.scrollview.refreshControl?.endRefreshing()
                HapticManager.shared.occurSuccess()
            }
            .disposed(by: bag)
        
        // 증상 추가 모달 띄우기
        output.goAddSymptom
            .bind(with: self) { owner, _ in
                let vc = AddSymptomVC()
                let fraction = UISheetPresentationController.Detent.custom { _ in owner.view.frame.height * 0.5 }
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [fraction]
                    sheet.preferredCornerRadius = .chuRadius // 모달 모서리 굴곡
                }
                // 창을 닫을 때 리로드 메시지 전송
                vc.dismissTask = { owner.symptomView.reloadCV.onNext(()) }
                owner.present(vc, animated: true)
            }
            .disposed(by: bag)
        
        
        output.presentRemoveAlert
            .bind(with: self) { owner, item in
                guard let item = item as? SymptomData else { return }
                owner.presentAlert(
                    title: String(localized: "알림"),
                    message: String(localized: "\"\(item.name)\" 증상을 목록에서 삭제할까요?"),
                    acceptTitle: String(localized: "삭제"),
                    acceptTask: {
                        SymptomDataManager.shared.delete(target: item) // 등록한 증상 삭제
                        owner.symptomView.reloadCV.onNext(()) // 리로드 메시지 전송
                    })
            }
            .disposed(by: bag)
            
        
        // input ===============================================================================================
//        symptomView.addButton
//            .rx.tap
//            .bind(to: homeVM.symptomsSubVM.input.tappedAddButton)
//            .disposed(by: bag)
        
//        symptomView.editButton
//            .rx.tap
//            .bind(to: homeVM.symptomsSubVM.input.tappedEditButton)
//            .disposed(by: bag)
        
        
        
        medicineView.addButton
            .rx.tap
            .bind(to: homeVM.medicineSubVM.input.tappedAddButton)
            .disposed(by: bag)
        
        medicineView.editButton
            .rx.tap
            .bind(to: homeVM.medicineSubVM.input.tappedEditButton)
            .disposed(by: bag)
        
//        goSettingsBarButton
//            .rx.tap
//            .bind(to: homeVM.input.tappedGoSettingsButton)
//            .disposed(by: bag)
        
        
        // 리프레시 인풋
//        scrollview.refreshControl?
//            .rx.controlEvent(.valueChanged)
//            .bind(to: homeVM.input.startRefreshing)
//            .disposed(by: bag)
        
        
        // output ===============================================================================================
        // 컬렉션 뷰 바인딩, 부작용
//        homeVM.symptomsSubVM.output.negativeCellData
//            .bind(to: symptomView.negativeCV.rx.items(dataSource: bindingCapsuleCellCV(SymptomSectionData.self)))
//            .disposed(by: bag)
        
        // 컬렉션 뷰 바인딩, 기타증상
//        homeVM.symptomsSubVM.output.otherCellData
//            .bind(to: symptomView.otherCV.rx.items(dataSource: bindingCapsuleCellCV(SymptomSectionData.self)))
//            .disposed(by: bag)
        
        // 컬렉션 뷰 바인딩, 복용중인 약
//        homeVM.medicineSubVM.output.cellData
//            .bind(to: medicineView.collectionView.rx.items(dataSource: bindingCapsuleCellCV(MedicineSectionData.self)))
//            .disposed(by: bag)
        
        
//        homeVM.symptomsSubVM.output.goAddSymptom
//            .bind(onNext: { [weak self] in
//                guard let self else { return }
//                
//                let vc = AddSymptomVC()
//                let fraction = UISheetPresentationController.Detent.custom { _ in self.view.frame.height * 0.5 }
//                if let sheet = vc.sheetPresentationController {
//                    sheet.detents = [fraction]
//                    sheet.preferredCornerRadius = .chuRadius // 모달 모서리 굴곡
//                }
//                vc.dismissTask = {
//                    self.homeVM.symptomsSubVM.input.reloadCV.onNext(()) // 컬렉션 뷰 리로드 이벤트 전송
//                    UIView.animate(withDuration: 0.5) {
//                        self.symptomView.updateCVHeight() // 컬렉션 뷰 레이아웃 재계산
//                        self.view.layoutIfNeeded()
//                    }
//                }
//                self.present(vc, animated: true)
//            })
//            .disposed(by: bag)
        
        
        homeVM.medicineSubVM.output.goAddMedicine
            .bind(onNext: { [weak self] in
                guard let self else { return }
                
                let vc = AddMedicineVC()
                let fraction = UISheetPresentationController.Detent.custom { _ in self.view.frame.height * 0.3 }
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [fraction]
                    sheet.preferredCornerRadius = .chuRadius // 모달 모서리 굴곡
                }
                vc.dismissTask = {
                    self.homeVM.medicineSubVM.input.reloadCV.onNext(()) // 컬렉션 뷰 리로드 이벤트 전송
                    UIView.animate(withDuration: 0.5) {
                        self.medicineView.updateCVHeight() // 컬렉션 뷰 레이아웃 재계산
                        self.view.layoutIfNeeded()
                    }
                }
                self.present(vc, animated: true)
            })
            .disposed(by: bag)
        
        
//        homeVM.output.goSettings
//            .bind(onNext: { [weak self] in
//                let vc = SettingsVC()
//                vc.hidesBottomBarWhenPushed = true
//                self?.navigationController?.pushViewController(vc, animated: true)
//            })
//            .disposed(by: bag)
        
        
        // 증상의 편집버튼을 누르면 버튼의 디자인이 바뀜
//        homeVM.symptomsSubVM.output.isEditMode
//            .bind(onNext: { [weak self] in self?.symptomView.updateEditButton(isEditMode: $0) })
//            .disposed(by: bag)
        
        
        // 증상이 등록된 게 없으면 이미지 표시
//        homeVM.symptomsSubVM.output.isDataEmpty
//            .bind(onNext: { [weak self] in self?.symptomView.setCVBackground(isNegativeEmpty: $0, isOtherEmpty: $1) })
//            .disposed(by: bag)
        
        
        // 복용중인 약의 편집버튼을 누르면 버튼의 디자인이 바뀜
        homeVM.medicineSubVM.output.isEditMode
            .bind(onNext: { [weak self] in self?.medicineView.updateEditButton(isEditMode: $0) })
            .disposed(by: bag)
        
        
        // 복용중인 약이 등록된 게 없으면 이미지 표시
        homeVM.medicineSubVM.output.isDataEmpty
            .bind(onNext: { [weak self] in self?.medicineView.setCVBackground(isEmpty: $0) })
            .disposed(by: bag)
        
        
        // 리프레시 아웃풋
//        homeVM.output.endRefreshing
//            .bind(onNext: { [weak self] in
//                self?.scrollview.refreshControl?.endRefreshing()
//                HapticManager.shared.occurSuccess()
//            })
//            .disposed(by: bag)
        
        
        // 달력 업데이트, 완료 얼럿
        homeVM.calendarSubVM.output.targetReloadDate
            .bind(onNext: { [weak self] in
                // 달력은 rx 바인딩이 안돼서 수동 업데이트
                self?.averageCalendarView.calendarView.reloadDecorations(forDateComponents: $0, animated: true)
            })
            .disposed(by: bag)
    }

}


extension HomeVC: EditButtonCellDelegate {
    // CapsuleCellModel을 사용하는 모든 컬렉션뷰들과 바인딩
    private func bindingCapsuleCellCV<T: AnimatableSectionModelType>( // 제네릭으로 타입 결정 지연
        _: T.Type // 컴파일러에게 T가 무슨 타입인지 알려주는 용도
    ) -> RxCollectionViewSectionedAnimatedDataSource<T> where T.Item: CapsuleCellModel { // CapsuleCellModel을 따르는 타입만 섹션데이터의 아이템으로 쓸 수 있게
        
        let animatedDataSource = RxCollectionViewSectionedAnimatedDataSource<T> {
            [weak self] animatedDataSource, collectionView, indexPath, item in
            
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: CapsuleCell.identifier, for: indexPath) as? CapsuleCell
            guard let cell, let self else { return UICollectionViewCell() }
            cell.setAttributes(item: item)
            cell.delegate = self
            return cell
        }
        
        // 애니메이션 구성 (생성자에서 구현해도 되긴 함)
        animatedDataSource.animationConfiguration = .init(
            insertAnimation: .fade,
            reloadAnimation: .fade,
            deleteAnimation: .fade)
        return animatedDataSource
    }
    
    
    func removeTask(item: any EditButtonCellModel) {
        switch item {
//        case let item as SymptomData:
//            presentAlert( // 얼럿 띄우기
//                title: String(localized: "알림"),
//                message: String(localized: "\"\(item.name)\" 증상을 목록에서 삭제할까요?"),
//                acceptTitle: String(localized: "삭제"),
//                acceptTask: { [weak self] in
//                    SymptomDataManager.shared.delete(target: item) // 등록한 증상 삭제
//                    self?.homeVM.symptomsSubVM.input.reloadCV.onNext(()) // 컬렉션 뷰 리로드 이벤트 전송
//                    UIView.animate(withDuration: 0.5) {
//                        self?.symptomView.updateCVHeight() // 컬렉션 뷰 레이아웃 재계산
//                        self?.view.layoutIfNeeded()
//                    }
//                })
            
        case let item as MedicineData:
            presentAlert( // 얼럿 띄우기
                title: String(localized: "알림"),
                message: String(localized: "\"\(item.name)\" 을 목록에서 삭제할까요?"),
                acceptTitle: String(localized: "삭제"),
                acceptTask: { [weak self] in
                    MedicineDataManager.shared.delete(target: item) // 등록한 증상 삭제
                    self?.homeVM.medicineSubVM.input.reloadCV.onNext(()) // 컬렉션 뷰 리로드 이벤트 전송
                    UIView.animate(withDuration: 0.5) {
                        self?.medicineView.updateCVHeight() // 컬렉션 뷰 레이아웃 재계산
                        self?.view.layoutIfNeeded()
                    }
                })
            
        default:
            print("오류발생", #function)
            return
        }
    }
}


extension HomeVC: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        var calendarData = [DateComponents : Int]()
        homeVM.calendarSubVM.output.calenderData
            .bind(onNext: { calendarData = $0 })
            .disposed(by: bag)
        
        // 일치하는 날짜에 value값이 있는지 확인, 없으면 nil
        let rate = calendarData
            .first { (key: DateComponents, _: Int) in
                if key.year == dateComponents.year,
                   key.month == dateComponents.month,
                   key.day == dateComponents.day {
                    return true
                }else{
                    return false
                }
            }
        
        guard let rate = rate?.value else { return nil }
        // 커스텀 라벨 미리 구현, 나중에 디테일한 구현 필요하면 컴포넌트에 사전 선언하는걸로
        let label = UILabel()
        label.text = rate.toNegativeName
        label.textColor = .chuBlack
        label.font = .boldSystemFont(ofSize: 12)
        return UICalendarView.Decoration.customView { return label }
    }

}



#Preview {
    TabBarVC()
}


