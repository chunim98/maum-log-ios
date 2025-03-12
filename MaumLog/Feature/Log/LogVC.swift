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
    
    // MARK: Interface
    
    let reloadSectionData = PublishSubject<Void>()
    private let itemToRemove = PublishSubject<EditButtonCellModel>()
    
    // MARK: Components
    
    private let barTitleLabel = {
        let label = UILabel()
        label.text = String(localized: "기록")
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .chuBlack
        return UIBarButtonItem(customView: label)
    }()
    
    fileprivate let optionBarButton = PullDownBarButton()
    fileprivate let editDoneBarButton = EndEditingBarButton()
    private let addBarButton = AddLogBarButton()
    
    fileprivate let logTV: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.register(SymptomLogCell.self, forCellReuseIdentifier: SymptomLogCell.identifier)
        tv.register(MedicineLogCell.self, forCellReuseIdentifier: MedicineLogCell.identifier)
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
    
    private let addFloatingButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "plus")?
            .resizeImage(newWidth: 30)
            .withRenderingMode(.alwaysTemplate)
        config.baseForegroundColor = .chuWhite
        config.baseBackgroundColor = .chuTint
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        button.layer.shadowOpacity = 0.75
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        return button
    }()
    
    private let takeMedicineButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "takeMedicine")?
            .resizeImage(newWidth: 25)
            .withRenderingMode(.alwaysTemplate) // 이거 안하면 이미지 색이 안바뀜
        config.baseForegroundColor = .chuWhite
        config.baseBackgroundColor = .chuTint
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        button.layer.shadowOpacity = 0.75
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        return button
    }()

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        setNavigationBar(
            leftBarButtonItems: [barTitleLabel],
            rightBarButtonItems: [optionBarButton, addBarButton]
        )
        setAutoLayout()
        setBinding()
    }
    
    // MARK: Layout
    
    private func setAutoLayout() {
        view.addSubview(logTV)
        view.addSubview(addFloatingButton)
        view.addSubview(takeMedicineButton)
        
        logTV.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        addFloatingButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.size.equalTo(50)
        }
        takeMedicineButton.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.bottom.equalTo(addFloatingButton.snp.top).offset(-15)
            $0.size.equalTo(35)
        }
    }
    
    // MARK: Binding
    
    private func setBinding() {
        let barButtonEvent = Observable.merge(
            addBarButton.rx.event,
            optionBarButton.rx.event,
            editDoneBarButton.rx.event
        )
        
        let input = LogVM.Input(
            barButtonEvent: barButtonEvent,
            reloadSectionData: reloadSectionData.asObservable(),
            tappedTakeMedicineButton: takeMedicineButton.rx.tap.asObservable(),
            itemToRemove: itemToRemove.asObservable()
        )
        let output = logVM.transform(input)

        // 로그 테이블 뷰 데이터 바인딩
        output.sectionData
            .bind(to: logTV.rx.items(dataSource: getLogDataSource()))
            .disposed(by: bag)
        
        // 기록 모달 띄우기
        output.goAddLog
            .bind(to: self.rx.pushAddLogBinder)
            .disposed(by: bag)
        
        // 등록한 증상이 없다면 증상 추가 모달 띄우기
        output.presentShouldAddSymptomAlert
            .bind(to: self.rx.presentShouldAddSymptomAlertBinder)
            .disposed(by: bag)
        
        // 편집 모드에 따른 바 버튼 상태 변경
        output.isEditMode
            .bind(to: self.rx.barButtonAppearance)
            .disposed(by: bag)
        
        // 기록이 없으면 이미지 표시
        output.logDataIsEmpty
            .bind(to: self.rx.logTVBackgroundView)
            .disposed(by: bag)
        
        // 등록한 약이 없다면 먼저 등록부터 하라는 얼럿 띄우기
        output.presentShouldAddMedicineAlert
            .bind(to: self.rx.presentShouldAddMedicineAlertBinder)
            .disposed(by: bag)
        
        // 약 먹었다는 얼럿 띄우기
        output.presentTakeMedicineAlert
            .bind(to: self.rx.presentTakeMedicineAlertBinder)
            .disposed(by: bag)

        // 정렬 변경
        output.isAscendingOrder
            .bind(to: optionBarButton.rx.sortState)
            .disposed(by: bag)
        
        output.presentRemoveAlert
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
        ) { [weak self] _, tableView, indexPath, item in
            guard let self else { return UITableViewCell() }
            
            if item.medicineCards.isEmpty {
                // 증상 기록을 표시해야 할 경우
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SymptomLogCell.identifier,
                    for: indexPath
                ) as? SymptomLogCell
                else { return UITableViewCell() }
                
                cell.configure(item: item)
                cell.itemToRemove
                    .bind(to: self.itemToRemove)
                    .disposed(by: cell.bag)
                return cell
                
            } else {
                // 복약 기록을 표시해야 할 경우
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: MedicineLogCell.identifier,
                    for: indexPath
                ) as? MedicineLogCell
                else { return UITableViewCell() }
                
                cell.configure(item: item)
                cell.itemToRemove
                    .bind(to: self.itemToRemove)
                    .disposed(by: cell.bag)
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
            vc.dismissTask = { base.reloadSectionData.onNext(()) }
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
            let barButton = $1 ? $0.editDoneBarButton : $0.optionBarButton
            $0.navigationItem.rightBarButtonItem = barButton
        }
    }
    
    fileprivate var logTVBackgroundView: Binder<Bool> {
        Binder(base) { $0.logTV.backgroundView = $1 ? $0.logEmptyView : .none }
    }
}
