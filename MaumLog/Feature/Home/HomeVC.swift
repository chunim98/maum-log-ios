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
import SnapKit

final class HomeVC: UIViewController {
    
    // MARK: Properties
    
    private let homeVM = HomeVM()
    private let bag = DisposeBag()
    
    // MARK: Components
    
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
    
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    let symptomView = SymptomSectionView()
    let medicineView = MedicineSectionView()
    let calendarView = CalendarSectionView()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        
        setNavigationBar(
            leftBarButtonItems: [UIBarButtonItem(customView: titleLabel)],
            rightBarButtonItems: [goSettingsBarButton]
        )
        setAutoLayout()
        setBinding()
    }
    
    // MARK: - Layout
    func setAutoLayout() {
        view.addSubview(scrollview)
        scrollview.addSubview(contentView)
        contentView.addSubview(mainVStack)
        mainVStack.addArrangedSubview(symptomView)
        mainVStack.addArrangedSubview(medicineView)
        mainVStack.addArrangedSubview(calendarView)
        
        scrollview.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        mainVStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 15, bottom: 50, right: 15))
        }
    }
    
    // MARK: - Binding
    func setBinding() {
        // 스크롤 뷰를 잡아당겼을 때 리프레쉬가 필요하다는 메시지 전달
        let startRefreshing = scrollview.refreshControl?
            .rx.controlEvent(.valueChanged).asObservable()
            .do(onNext: { [weak self] _ in
                self?.symptomView.rx.reloadBinder.onNext(())
                self?.medicineView.rx.reloadBinder.onNext(())
                self?.calendarView.rx.reloadBinder.onNext(())
            }) ?? .empty() // nil이면 아무것도 방출하지 않고 스트림 종료

        let input = HomeVM.Input(
            tappedGoSettingsButton: goSettingsBarButton.rx.tap.asObservable(),
            startRefreshing: startRefreshing,
            goAddSymptom: symptomView.rx.addButtonTapEvent,
            presentRemoveSymptomAlert: symptomView.rx.itemToRemove,
            goAddMedicine: medicineView.rx.addButtonTapEvent,
            presentRemoveMedicineAlert: medicineView.rx.itemToRemove
        )
        
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
                vc.dismissTask = { owner.symptomView.rx.reloadBinder.onNext(()) }
                owner.present(vc, animated: true)
            }
            .disposed(by: bag)
        
        // 증상, 약물 삭제 확인 얼럿 띄우기
        output.presentRemoveAlert
            .bind(with: self) { owner, item in
                owner.presentRemoveAlert(item: item)
            }
            .disposed(by: bag)
        
        // 약물 추가 모달 띄우기
        output.goAddMedicine
            .bind(with: self) { owner, _ in
                let vc = AddMedicineVC()
                let fraction = UISheetPresentationController.Detent.custom { _ in owner.view.frame.height * 0.3 }
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [fraction]
                    sheet.preferredCornerRadius = .chuRadius // 모달 모서리 굴곡
                }
                // 창을 닫을 때 리로드 메시지 전송
                vc.dismissTask = { owner.medicineView.rx.reloadBinder.onNext(()) }
                owner.present(vc, animated: true)
            }
            .disposed(by: bag)
    }
}

#Preview {
    TabBarVC()
}


