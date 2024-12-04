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
    
    // MARK: - Components
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
    
    // MARK: - Life Cycle
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
            medicineView.setCVLayout()
        }
    }
    
    // MARK: - Layout
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
    
    // MARK: - Binding
    func setBinding() {
        
        // 스크롤 뷰를 잡아당겼을 때 리프레쉬가 필요하다는 메시지 전달
        let startRefreshing = scrollview.refreshControl?
            .rx.controlEvent(.valueChanged).asObservable() ?? .empty()

        let input = HomeVM.Input(
            tappedGoSettingsButton: goSettingsBarButton.rx.tap.asObservable(),
            startRefreshing: startRefreshing,
            goAddSymptom: symptomView.goAddSymptom.asObservable(),
            presentRemoveAlert: symptomView.presentRemoveAlert.asObservable(),
            goAddMedicine: medicineView.goAddMedicine.asObservable(),
            presentRemoveMedicineAlert: medicineView.presentRemoveMedicineAlert.asObservable())
        
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
        
        output.goAddMedicine
            .bind(with: self) { owner, _ in
                let vc = AddMedicineVC()
                let fraction = UISheetPresentationController.Detent.custom { _ in owner.view.frame.height * 0.3 }
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [fraction]
                    sheet.preferredCornerRadius = .chuRadius // 모달 모서리 굴곡
                }
                // 창을 닫을 때 리로드 메시지 전송
                vc.dismissTask = { owner.medicineView.reloadCV.onNext(()) }
                owner.present(vc, animated: true)
            }
            .disposed(by: bag)
        
        output.presentRemoveMedicineAlert
            .bind(with: self) { owner, item in
                guard let item = item as? MedicineData else { return }
                owner.presentAlert(
                    title: String(localized: "알림"),
                    message: String(localized: "\"\(item.name)\" 을 목록에서 삭제할까요?"),
                    acceptTitle: String(localized: "삭제"),
                    acceptTask: {
                        MedicineDataManager.shared.delete(target: item) // 등록한 약물 삭제
                        owner.medicineView.reloadCV.onNext(()) // 리로드 이벤트 전송
                    })
            }
            .disposed(by: bag)
            
        // MARK: - Legacies
        // 달력 업데이트, 완료 얼럿
        homeVM.calendarSubVM.output.targetReloadDate
            .bind(onNext: { [weak self] in
                // 달력은 rx 바인딩이 안돼서 수동 업데이트
                self?.averageCalendarView.calendarView.reloadDecorations(forDateComponents: $0, animated: true)
            })
            .disposed(by: bag)
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


