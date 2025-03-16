//
//  ViewController.swift
//  MaumLog
//
//  Created by 신정욱 on 7/26/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class HomeVC: UIViewController {
    
    // MARK: Properties
    
    private let homeVM = HomeVM()
    private let bag = DisposeBag()
    
    // MARK: Components
    
    private let titleLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .chuBlack
        label.text = "대시보드"
        return label
    }()
    
    private let settingsBarButton = {
        let barButton = UIBarButtonItem(
            image: UIImage(named: "gear")?.resizeImage(newWidth: 24),
            style: .plain,
            target: .none,
            action: .none
        )
        barButton.tintColor = .chuBlack
        return barButton
    }()
    
    fileprivate let scrollView = {
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(
            string: "당겨서 새로고침",
            attributes: [.foregroundColor : UIColor.gray]
        )
        let view = UIScrollView()
        view.backgroundColor = .chuIvory
        view.refreshControl = refresh
        view.clipsToBounds = false
        return view
    }()
    
    private let contentView = {
        let view = UIView()
        view.backgroundColor = .chuIvory
        view.clipsToBounds = false
        return view
    }()
    
    private let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    fileprivate let symptomView = SymptomSectionView()
    fileprivate let medicineView = MedicineSectionView()
    private let calendarView = CalendarSectionView()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(
            leftBarButtonItems: [UIBarButtonItem(customView: titleLabel)],
            rightBarButtonItems: [settingsBarButton]
        )
        setAutoLayout()
        setBinding()
    }
    
    // MARK: Layout
    
    func setAutoLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainVStack)
        mainVStack.addArrangedSubview(symptomView)
        mainVStack.addArrangedSubview(medicineView)
        mainVStack.addArrangedSubview(calendarView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        mainVStack.snp.makeConstraints {
            let inset = UIEdgeInsets(top: 20, left: 15, bottom: 50, right: 15)
            $0.edges.equalToSuperview().inset(inset)
        }
    }
    
    // MARK: Binding
    
    func setBinding() {
        let refreshEvnet = scrollView.refreshControl?
            .rx.controlEvent(.valueChanged)
            .asObservable() ?? .empty()

        let input = HomeVM.Input(
            refreshEvnet: refreshEvnet,
            pushSettingsEvent: settingsBarButton.rx.tap.asObservable(),
            pushAddSymptomEvent: symptomView.rx.addButtonTapEvent,
            pushAddMedicineEvent: medicineView.rx.addButtonTapEvent,
            symptomToRemove: symptomView.rx.itemToRemove,
            medicineToRemove: medicineView.rx.itemToRemove
        )
        let output = homeVM.transform(input)
        
        // 리프레시 컨트롤의 데이터 갱신 요청
        output.refreshEvnet
            .bind(
                to: symptomView.rx.reloadBinder,
                medicineView.rx.reloadBinder,
                calendarView.rx.reloadBinder
            )
            .disposed(by: bag)
        
        // 리프레쉬 종료
        output.refreshEvnet
            .bind(to: self.rx.endRefreshBinder)
            .disposed(by: bag)
        
        // 설정 화면 이동
        output.pushSettingsEvent
            .bind(to: self.rx.pushSettingsBinder)
            .disposed(by: bag)
        
        // 증상 추가 모달 띄우기
        output.pushAddSymptomEvent
            .bind(to: self.rx.pushAddSymptomBinder)
            .disposed(by: bag)
        
        // 약물 추가 모달 띄우기
        output.pushAddMedicineEvent
            .bind(to: self.rx.pushAddMedicineBinder)
            .disposed(by: bag)
        
        // 증상, 약물 삭제 확인 얼럿 띄우기
        output.itemToRemove
            .bind(to: self.rx.presentRemoveAlertBinder)
            .disposed(by: bag)
    }
}

#Preview { TabBarVC() }

// MARK: - Reactive

extension Reactive where Base: HomeVC {
    
    fileprivate var endRefreshBinder: Binder<Void> {
        Binder(base) { base, _ in
            base.scrollView.refreshControl?.endRefreshing()
            HapticManager.shared.occurSuccess()
        }
    }
    
    fileprivate var pushSettingsBinder: Binder<Void> {
        Binder(base) { base, _ in
            let vc = SettingsVC()
            vc.hidesBottomBarWhenPushed = true
            base.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    fileprivate var pushAddSymptomBinder: Binder<Void> {
        Binder(base) { base, _ in
            let fraction = UISheetPresentationController.Detent.custom { _ in
                base.view.frame.height * 0.5
            }
            let vc = AddSymptomVC()
            vc.sheetPresentationController?.detents = [fraction]
            vc.sheetPresentationController?.preferredCornerRadius = 15 // 모달 모서리 굴곡
            vc.dismissTask = { base.symptomView.rx.reloadBinder.onNext(()) } // 창 닫을 때, 새로고침
            base.present(vc, animated: true)
        }
    }
    
    fileprivate var pushAddMedicineBinder: Binder<Void> {
        Binder(base) { base, _ in
            let fraction = UISheetPresentationController.Detent.custom { _ in
                base.view.frame.height * 0.3
            }
            let vc = AddMedicineVC()
            vc.sheetPresentationController?.detents = [fraction]
            vc.sheetPresentationController?.preferredCornerRadius = 15 // 모달 모서리 굴곡
            vc.dismissTask = { base.medicineView.rx.reloadBinder.onNext(()) } // 창 닫을 때, 새로고침
            base.present(vc, animated: true)
        }
    }
    
    fileprivate var presentRemoveAlertBinder: Binder<EditButtonCellModel> {
        Binder(base) { $0.presentRemoveAlert(item: $1) }
    }
}

// MARK: - Alerts

extension HomeVC {
    func presentRemoveAlert(item: any EditButtonCellModel) {
        switch item {
        case let item as SymptomData:
            presentAlert(
                title: "알림",
                message: "\"\(item.name)\" 증상을 목록에서 삭제할까요?",
                acceptTitle: "삭제",
                acceptTask: {
                    SymptomDataManager.shared.delete(target: item) // 등록한 증상 삭제
                    self.symptomView.rx.reloadBinder.onNext(()) // 리로드 메시지 전송
                }
            )
            
        case let item as MedicineData:
            presentAlert(
                title: "알림",
                message: "\"\(item.name)\" 을 목록에서 삭제할까요?",
                acceptTitle: "삭제",
                acceptTask: {
                    MedicineDataManager.shared.delete(target: item) // 등록한 약물 삭제
                    self.medicineView.rx.reloadBinder.onNext(()) // 리로드 이벤트 전송
                }
            )
            
        default:
            print(#function, "예외 발생")
        }
    }
}


