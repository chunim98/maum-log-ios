//
//  LogVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/4/24.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

final class LogVC: UIViewController {
    
    typealias DataSource = RxTableViewSectionedAnimatedDataSource
    
    // MARK: Properties

    private let logVM = LogVM()
    private let bag = DisposeBag()
    weak var coordinator: Coordinator?
    
    // MARK: Interface
    
    fileprivate let reloadEvent = PublishSubject<Void>()
    
    // MARK: Components
    
    private let barTitleLabel = {
        let label = UILabel()
        label.text = "기록"
        label.textColor = .chuBlack
        label.font = .boldSystemFont(ofSize: 24)
        return UIBarButtonItem(customView: label)
    }()
    
    fileprivate let pullDownBarButton = PullDownBarButton()
    fileprivate let endEditingBarButton = EndEditingBarButton()
    private let addLogBarButton = AddLogBarButton()
    
    fileprivate let logTV: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.register(
            SymptomLogCell.self,
            forCellReuseIdentifier: SymptomLogCell.identifier
        )
        tv.register(
            MedicineLogCell.self,
            forCellReuseIdentifier: MedicineLogCell.identifier
        )
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.clipsToBounds = false
        return tv
    }()
    
    fileprivate let logEmptyView = EmptyView(
        text: "+ 버튼을 눌러 기록을 시작할 수 있어요.",
        textSize: 18,
        image: UIImage(named: "emptyLog"),
        spacing: 30
    )
    
    private let addLogButton = CircleButton(
        UIImage(named: "plus")?.resizeImage(newWidth: 30)
    )
    
    private let intakeButton = CircleButton(
        UIImage(named: "takeMedicine")?.resizeImage(newWidth: 25)
    )

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        
        setNavigationBar(
            leftBarButtonItems: [barTitleLabel],
            rightBarButtonItems: [pullDownBarButton, addLogBarButton]
        )
        setAutoLayout()
        setBinding()
    }
    
    // MARK: Layout
    
    private func setAutoLayout() {
        view.addSubview(logTV)
        view.addSubview(addLogButton)
        view.addSubview(intakeButton)
        
        logTV.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        addLogButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.size.equalTo(50)
        }
        intakeButton.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.bottom.equalTo(addLogButton.snp.top).offset(-15)
            $0.size.equalTo(35)
        }
    }
    
    // MARK: Binding
    
    private func setBinding() {
        let buttonEvent = Observable.merge(
            addLogBarButton.rx.event,
            pullDownBarButton.rx.event,
            endEditingBarButton.rx.event,
            intakeButton.rx.tap.map { _ in LogButtonEvent.intake },
            addLogButton.rx.tap.map { _ in LogButtonEvent.pushAddLog }
        )
        
        let input = LogVM.Input(
            buttonEvent: buttonEvent,
            reloadEvent: reloadEvent.asObservable(),
            selectedModel: logTV.rx.modelSelected(EditButtonCellModel.self).asObservable()
        )
        let output = logVM.transform(input)

        // 로그 테이블 뷰 데이터 바인딩
        output.logSectionDataArr
            .bind(to: logTV.rx.items(dataSource: getLogDataSource()))
            .disposed(by: bag)
        
        // 기록 모달 띄우기
        output.pushAddLogEvent
            .bind(to: self.rx.pushAddLogBinder)
            .disposed(by: bag)
        
        // 등록한 증상이 없다면 증상 추가 모달 띄우기
        output.presentShouldAddSymptomAlertEvent
            .bind(to: self.rx.presentShouldAddSymptomAlertBinder)
            .disposed(by: bag)
        
        // 편집 모드에 따른 바 버튼 상태 변경
        output.isEditing
            .bind(to: self.rx.barButtonAppearance)
            .disposed(by: bag)
        
        // 기록이 없다면 백그라운드 뷰 표시
        output.isDataEmpty
            .bind(to: self.rx.logTVBackgroundView)
            .disposed(by: bag)
        
        // 등록한 약이 없다면 먼저 등록부터 하라는 얼럿 띄우기
        output.presentShouldAddMedicineAlertEvent
            .bind(to: self.rx.presentShouldAddMedicineAlertBinder)
            .disposed(by: bag)
        
        // 약 먹었다는 얼럿 띄우기
        output.presentTakeMedicineAlertEvent
            .bind(to: self.rx.presentTakeMedicineAlertBinder)
            .disposed(by: bag)

        // 정렬 변경
        output.isAscendingOrder
            .bind(to: pullDownBarButton.rx.sortState)
            .disposed(by: bag)
        
        // 삭제할 기록 바인딩
        output.itemToRemove
            .bind(to: self.rx.presentRemoveAlertBinder)
            .disposed(by: bag)
    }
    
    // MARK: Rx Data Sources

    private func getLogDataSource() -> DataSource<LogSectionData> {
        
        let animeConfig = AnimationConfiguration(
            insertAnimation: .fade,
            reloadAnimation: .fade,
            deleteAnimation: .fade
        )
        
        let dataSource = DataSource<LogSectionData>(
            animationConfiguration: animeConfig
        ) { _, tableView, indexPath, item in
            if item.medicineCards.isEmpty {
                // 증상 기록을 표시해야 할 경우
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SymptomLogCell.identifier,
                    for: indexPath
                ) as? SymptomLogCell
                else { return UITableViewCell() }
                cell.configure(item)
                return cell
                
            } else {
                // 복약 기록을 표시해야 할 경우
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: MedicineLogCell.identifier,
                    for: indexPath
                ) as? MedicineLogCell
                else { return UITableViewCell() }
                cell.configure(item)
                return cell
            }
        }

        // 헤더 추가, 파라미터(dataSource, indexPath)
        dataSource.titleForHeaderInSection = { $0.sectionModels[$1].header }
        
        // 추가 설정
        // animatedDataSource.canEditRowAtIndexPath = {dataSource, indexPath in true}
        // animatedDataSource.canMoveRowAtIndexPath = {dataSource, indexPath in true}
        
        return dataSource
    }
}

#Preview { TabBarVC() }

// MARK: - Reactive

extension Reactive where Base: LogVC {
    
    fileprivate var pushAddLogBinder: Binder<Void> {
        Binder(base) { base, _ in
            let fraction = UISheetPresentationController.Detent.custom { _ in
                base.view.frame.height * 0.8
            }
            let vc = AddLogVC()
            vc.sheetPresentationController?.detents = [fraction, .large()]
            vc.sheetPresentationController?.preferredCornerRadius = .chuRadius
            vc.sheetPresentationController?.prefersGrabberVisible = true
            vc.dismissTask = { base.reloadEvent.onNext(()) }
            base.present(vc, animated: true)
        }
    }
    
    fileprivate var presentShouldAddSymptomAlertBinder: Binder<Void> {
        Binder(base) { base, _ in base.presentShouldAddSymptomAlert() }
    }
    
    fileprivate var presentShouldAddMedicineAlertBinder: Binder<Void> {
        Binder(base) { base, _ in base.presentShouldAddMedicineAlert() }
    }
    
    fileprivate var presentTakeMedicineAlertBinder: Binder<Void> {
        Binder(base) { base, _ in
            base.presentAcceptAlert(title: "기록 완료", message: "복약한 시간을 기록했어요.")
        }
    }
    
    fileprivate var presentRemoveAlertBinder: Binder<EditButtonCellModel> {
        Binder(base) { $0.presentRemoveAlert(item: $1) }
    }
    
    fileprivate var barButtonAppearance: Binder<Bool> {
        Binder(base) {
            let barButton = $1 ? $0.endEditingBarButton : $0.pullDownBarButton
            $0.navigationItem.rightBarButtonItem = barButton
        }
    }
    
    fileprivate var logTVBackgroundView: Binder<Bool> {
        Binder(base) { $0.logTV.backgroundView = $1 ? $0.logEmptyView : .none }
    }
}

// MARK: - Alerts

extension LogVC {
    func presentShouldAddSymptomAlert() {
        presentAlert(
            title: String(localized: "알림"),
            message: String(localized: "부작용, 기타 증상을 기록하려면\n먼저 증상을 등록해야 해요."),
            acceptTitle: String(localized: "등록"),
            acceptTask: { [weak self] in
                guard let self else { return }
                
                // 모달 높이 조정
                let fraction = UISheetPresentationController.Detent.custom { _ in self.view.frame.height * 0.6 }

                let vc = AddSymptomVC()
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [fraction]
                    sheet.preferredCornerRadius = .chuRadius
                }
                
                present(vc, animated: true)
            })
    }
    
    func presentShouldAddMedicineAlert() {
        presentAlert(
            title: String(localized: "알림"),
            message: String(localized: "복약한 시간을 기록하려면\n먼저 복용 중인 약을 등록해야 해요."),
            acceptTitle: String(localized: "등록"),
            acceptTask: { [weak self] in
                guard let self else { return }

                // 모달 높이 조정
                let fraction = UISheetPresentationController.Detent.custom { _ in self.view.frame.height * 0.3 }

                let vc = AddMedicineVC()
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [fraction]
                    sheet.preferredCornerRadius = .chuRadius
                }
                
                present(vc, animated: true)
            })
    }
    
    func presentRemoveAlert(item: any EditButtonCellModel) {
        guard let item = item as? LogData else { return }
        
        presentAlert(
            title: String(localized: "알림"),
            message: String(localized: "기록을 삭제할까요?"),
            acceptTitle: String(localized: "삭제"),
            acceptTask: { [weak self] in
                LogDataManager.shared.delete(target: item)
                self?.reloadEvent.onNext(())
            })
    }
}
