//
//  LogVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/4/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class LogVC: UIViewController {
    typealias SectionDataSource = RxTableViewSectionedAnimatedDataSource

    private let logVM = LogVM()
    private let bag = DisposeBag()
    
    let reloadSectionData = PublishSubject<Void>()
    private let tappedEditButton = PublishSubject<Void>()
    private let changeSorting = PublishSubject<Bool>()
    private let itemToRemove = PublishSubject<EditButtonCellModel>()
    
    // MARK: - Components
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "기록")
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .chuBlack
        return label
    }()
    
    let optionBarButton = {
        let image = UIImage(systemName: "ellipsis")?.applyingSymbolConfiguration(.init(pointSize: 18))
        let barButton = UIBarButtonItem(image: image, style: .plain, target: .none, action: .none)
        barButton.tintColor = .chuBlack
        return barButton
    }()
    
    let editDoneBarButton = {
        let button = UIBarButtonItem()
        button.title = String(localized: "완료")
        button.tintColor = .chuBlack
        return button
    }()
    
    let addBarButton = {
        let image = UIImage(named: "plus")?.resizeImage(newWidth: 18)
        let barButton = UIBarButtonItem(image: image, style: .plain, target: .none, action: .none)
        barButton.tintColor = .chuBlack
        return barButton
    }()
    
    let logTV: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.register(SymptomLogCell.self, forCellReuseIdentifier: SymptomLogCell.identifier)
        tv.register(MedicineLogCell.self, forCellReuseIdentifier: MedicineLogCell.identifier)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.clipsToBounds = false
        return tv
    }()
    
    let logEmptyView = EmptyView(
        text: String(localized: "+ 버튼을 눌러 기록을 시작할 수 있어요."),
        textSize: 18,
        image: UIImage(named: "emptyLog"),
        spacing: 30)
    
    let addFloatingButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "plus")?
            .resizeImage(newWidth: 30)
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
    
    let takeMedicineButton: UIButton = {
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
    
    // 풀다운 버튼의 오름차순 정렬 옵션
    var ascendingOrder: UIAction!
    
    // 풀다운 버튼의 내림차순 정렬 옵션
    var descendingOrder: UIAction!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        setNavigationBar(
            leftBarButtonItems: [UIBarButtonItem(customView: titleLabel)],
            rightBarButtonItems: [optionBarButton, addBarButton])
        setPullDownButton()
        setAutoLayout()
        setBinding()
    }
    
    // MARK: - Layout
    func setAutoLayout() {
        view.addSubview(logTV)
        view.addSubview(addFloatingButton)
        view.addSubview(takeMedicineButton)
        
        logTV.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        addFloatingButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.size.equalTo(50)
        }
        takeMedicineButton.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.bottom.equalTo(addFloatingButton.snp.top).inset(-15)
            $0.size.equalTo(35)
        }
    }
    
    // MARK: - Binding
    func setBinding() {
        let tappedAddButton = Observable.merge(
            addFloatingButton.rx.tap.asObservable(),
            addBarButton.rx.tap.asObservable())
        
        let input = LogVM.Input(
            tappedAddButton: tappedAddButton,
            reloadSectionData: reloadSectionData.asObservable(),
            tappedEditButton: tappedEditButton.asObservable(),
            tappedEditDoneButton: editDoneBarButton.rx.tap.asObservable(),
            changeSorting: changeSorting.asObservable(),
            tappedTakeMedicineButton: takeMedicineButton.rx.tap.asObservable(),
            itemToRemove: itemToRemove.asObservable())
        
        let output = logVM.transform(input)

        // 로그 테이블 뷰 데이터 바인딩
        output.sectionData
            .bind(to: logTV.rx.items(dataSource: bindingTableView()))
            .disposed(by: bag)
        
        // 기록 모달 띄우기
        output.goAddLog
            .bind(with: self, onNext: { owner, _ in
                // 모달 높이 조정
                let fraction = UISheetPresentationController.Detent.custom { _ in
                    owner.view.frame.height * 0.8
                }

                let vc = AddLogVC()
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [fraction, .large()]
                    sheet.preferredCornerRadius = .chuRadius
                    sheet.prefersGrabberVisible = true
                }
                
                vc.dismissTask = { owner.reloadSectionData.onNext(()) }
                owner.present(vc, animated: true)
            })
            .disposed(by: bag)
        
        // 등록한 증상이 없다면 증상 추가 모달 띄우기
        output.presentShouldAddSymptomAlert
            .bind(with: self, onNext: { owner, _ in
                owner.presentShouldAddSymptomAlert()
            })
            .disposed(by: bag)
        
        // 편집 모드에 따른 바 버튼 상태 변경
        output.isEditMode
            .bind(with: self) { owner, isEditMode in
                if isEditMode {
                    owner.navigationItem.rightBarButtonItem = owner.editDoneBarButton
                } else {
                    owner.navigationItem.rightBarButtonItem = owner.optionBarButton
                }
            }
            .disposed(by: bag)
        
        // 기록이 없으면 이미지 표시
        output.logDataIsEmpty
            .bind(with: self) { owner, isLogDataEmpty in
                if isLogDataEmpty {
                    owner.logTV.backgroundView = owner.logEmptyView
                } else {
                    owner.logTV.backgroundView = .none
                }
            }
            .disposed(by: bag)
        
        // 등록한 약이 없다면 먼저 등록부터 하라는 얼럿 띄우기
        output.presentShouldAddMedicineAlert
            .bind(with: self) { owner, _ in
                owner.presentShouldAddMedicineAlert()
            }
            .disposed(by: bag)
        
        // 약 먹었다는 얼럿 띄우기
        output.presentTakeMedicineAlert
            .bind(with: self) { owner, _ in
                owner.presentAcceptAlert(
                    title: String(localized: "기록 완료"),
                    message: String(localized: "복약한 시간을 기록했어요."))
            }
            .disposed(by: bag)

        // 정렬 변경
        output.isAscendingOrder
            .bind(with: self) { owenr, isAscendingOrder in
                if isAscendingOrder {
                    owenr.descendingOrder.state = .on
                } else {
                    owenr.ascendingOrder.state = .on
                }
            }
            .disposed(by: bag)
        
        output.presentRemoveAlert
            .bind(with: self) { owner, item in
                owner.presentRemoveAlert(item: item)
            }
            .disposed(by: bag)
    }
    
    // MARK: - Configure Components
    private func setPullDownButton() {
        let edit = UIAction(
            title: String(localized: "편집"),
            image: UIImage(systemName: "square.and.pencil"),
            handler: { [weak self] _ in self?.tappedEditButton.onNext(()) })

        ascendingOrder = UIAction(
            title: String(localized: "최신 항목 순으로"),
            handler: { [weak self] _ in self?.changeSorting.onNext(false) })
        
        descendingOrder = UIAction(
            title: String(localized: "오래된 항목 순으로"),
            handler: { [weak self] _ in self?.changeSorting.onNext(true) })
        
        // 팝업버튼 설정
        let sortByMenu = UIMenu(
            title: String(localized: "다음으로 정렬"),
            image: UIImage(systemName: "arrow.up.arrow.down"),
            options: .singleSelection ,
            children: [ascendingOrder, descendingOrder])
        
        let menu = UIMenu(title: String(localized: "옵션"), children: [edit, sortByMenu])
        
        optionBarButton.menu = menu
    }
    
    // 테이블 뷰 바인딩
    private func bindingTableView() -> SectionDataSource<LogSectionData> {
        
        let animatedDataSource = SectionDataSource<LogSectionData> { [weak self] animatedDataSource, tableView, indexPath, item in
            guard let self else { return UITableViewCell() }
            
            if item.medicineCards.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: SymptomLogCell.identifier, for: indexPath) as? SymptomLogCell
                guard let cell else { return UITableViewCell() }

                cell.configure(item: item)
                cell.itemToRemove
                    .bind(to: self.itemToRemove)
                    .disposed(by: bag)
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: MedicineLogCell.identifier, for: indexPath) as? MedicineLogCell
                guard let cell else { return UITableViewCell() }

                cell.configure(item: item)
                cell.itemToRemove
                    .bind(to: self.itemToRemove)
                    .disposed(by: bag)
                
                return cell
            }
        }

        // 애니메이션 구성 (생성자에서 구현해도 되긴 함)
        animatedDataSource.animationConfiguration = .init(
            insertAnimation: .bottom,
            reloadAnimation: .left,
            deleteAnimation: .fade)

        // 헤더 사용하고 싶다면 추가
        animatedDataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header // LogSectionData 의 header
        }
        
        // 추가로 요렇게 설정 가능
        // animatedDataSource.canEditRowAtIndexPath = {dataSource, indexPath in true}
        // animatedDataSource.canMoveRowAtIndexPath = {dataSource, indexPath in true}
        
        return animatedDataSource
    }
}

#Preview {
    TabBarVC()
}
