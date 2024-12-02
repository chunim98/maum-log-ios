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
    
    private let logVM = LogVM()
    private let bag = DisposeBag()
    
    // MARK: - 컴포넌트
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
    


    // MARK: - 라이프 사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        
        setAutoLayout()
        setBinding()
        setNavigationBar(
            leftBarButtonItems: [UIBarButtonItem(customView: titleLabel)],
            rightBarButtonItems: [optionBarButton, addBarButton])
        setPullDownButton()
    }
    
    // MARK: - 오토레이아웃
    func setAutoLayout() {
        view.addSubview(logTV)
        view.addSubview(addFloatingButton)
        view.addSubview(takeMedicineButton)
        
        logTV.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        addFloatingButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.size.equalTo(50)
        }
        takeMedicineButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.bottom.equalTo(addFloatingButton.snp.top).inset(-15)
            make.size.equalTo(35)
        }
    }
    
    // MARK: - 바인딩
    func setBinding() {
        // input
        addFloatingButton
            .rx.tap
            .bind(to: logVM.input.tappedAddButton)
            .disposed(by: bag)
        
        addBarButton
            .rx.tap
            .bind(to: logVM.input.tappedAddButton)
            .disposed(by: bag)
        
        editDoneBarButton
            .rx.tap
            .bind(to: logVM.input.tappedEditDoneButton)
            .disposed(by: bag)
        
        takeMedicineButton
            .rx.tap
            .bind(to: logVM.input.tappedTakeMedicineButton)
            .disposed(by: bag)
        
        
        // output
        logVM.output.sectionData
            .bind(to: logTV.rx.items(dataSource: bindingTableView()))
            .disposed(by: bag)
        
        
        logVM.output.goAddLog
            .bind(onNext: { [weak self] in
                // 등록된 증상이 있어야 기록 추가 가능
                guard let self, $0 else { return }
                
                let vc = AddLogVC()
                let fraction = UISheetPresentationController.Detent.custom { _ in self.view.frame.height * 0.8 }
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [fraction, .large()]
                    sheet.preferredCornerRadius = .chuRadius
                    sheet.prefersGrabberVisible = true
                }
                vc.dismissTask = { self.logVM.input.reloadSectionData.onNext(()) }
                self.present(vc, animated: true)
            })
            .disposed(by: bag)
        
        
        logVM.output.shouldAddSymptom
            .bind(onNext: { [weak self] in
                // 등록된 증상이 있다면 실행조차 안됨
                guard let self, $0 else { return }
                
                presentAlert(
                    title: String(localized: "알림"),
                    message: String(localized: "부작용, 기타 증상을 기록하려면\n먼저 증상을 등록해야 해요."),
                    acceptTitle: String(localized: "등록"),
                    acceptTask: {
                        let vc = AddSymptomVC()
                        let fraction = UISheetPresentationController.Detent.custom { _ in self.view.frame.height * 0.6 }
                        if let sheet = vc.sheetPresentationController {
                            sheet.detents = [fraction]
                            sheet.preferredCornerRadius = .chuRadius // 모달 모서리 굴곡
                        }
                        self.present(vc, animated: true)
                    })
            })
            .disposed(by: bag)
        
        
        logVM.output.isEditMode
            .bind(onNext: { [weak self] in
                if $0 {
                    self?.navigationItem.rightBarButtonItem = self?.editDoneBarButton
                }else{
                    self?.navigationItem.rightBarButtonItem = self?.optionBarButton
                }
            })
            .disposed(by: bag)
        
        
        // 기록이 없으면 이미지 표시
        logVM.output.logDataIsEmpty
            .bind(onNext: { [weak self] in
                if $0 {
                    self?.logTV.backgroundView = self?.logEmptyView
                }else{
                    self?.logTV.backgroundView = .none
                }
            })
            .disposed(by: bag)
        
        
        // 복용중인 약이 없으면 등록 유도
        logVM.output.shouldAddMedicine
            .bind(onNext: { [weak self] in
                guard let self else { return }
                
                if $0 {
                    // 등록을 선택하면 모달 띄우기
                    presentAlert(
                        title: String(localized: "알림"),
                        message: String(localized: "복약한 시간을 기록하려면\n먼저 복용 중인 약을 등록해야 해요."),
                        acceptTitle: String(localized: "등록"),
                        acceptTask: {
                            let vc = AddMedicineVC()
                            let fraction = UISheetPresentationController.Detent.custom { _ in self.view.frame.height * 0.3 }
                            if let sheet = vc.sheetPresentationController {
                                sheet.detents = [fraction]
                                sheet.preferredCornerRadius = .chuRadius // 모달 모서리 굴곡
                            }
                            self.present(vc, animated: true)
                        })
                    
                } else {
                    presentAcceptAlert(
                        title: String(localized: "기록 완료"),
                        message: String(localized: "복약한 시간을 기록했어요."),
                        acceptTask: {
                            self.logVM.input.takeMedicine.onNext(())
                        })
                }
                
            })
            .disposed(by: bag)

    }
    
    // MARK: - 컴포넌트 구성
    private func setPullDownButton() {
        let edit = UIAction(
            title: String(localized: "편집"),
            image: UIImage(systemName: "square.and.pencil"),
            handler: { [weak self] _ in self?.logVM.input.tappedEditButton.onNext(()) })

        let ascendingOrder = UIAction(
            title: String(localized: "최신 항목 순으로"),
            handler: { [weak self] _ in self?.logVM.input.changeSorting.onNext(false) })
        
        let descendingOrder = UIAction(
            title: String(localized: "오래된 항목 순으로"),
            handler: { [weak self] _ in self?.logVM.input.changeSorting.onNext(true) })
        
        //output
        logVM.output.isAscendingOrder
            .bind(onNext: {
                if $0 {
                    descendingOrder.state = .on
                }else{
                    ascendingOrder.state = .on
                }
            })
            .disposed(by: bag)
        
        // 팝업버튼 설정
        let sortByMenu: UIMenu = {
            return UIMenu(
                title: String(localized: "다음으로 정렬"),
                image: UIImage(systemName: "arrow.up.arrow.down"),
                options: .singleSelection ,
                children: [ascendingOrder, descendingOrder])
        }()
        
        let menu: UIMenu = {
            return UIMenu(title: String(localized: "옵션"), children: [edit, sortByMenu])
        }()
        
        optionBarButton.menu = menu
    }

}


extension LogVC: EditButtonCellDelegate {
    // 테이블 뷰 바인딩
    private func bindingTableView() -> RxTableViewSectionedAnimatedDataSource<LogSectionData> {
        
        let animatedDataSource = RxTableViewSectionedAnimatedDataSource<LogSectionData> { 
            [weak self] animatedDataSource, tableView, indexPath, item in
            guard let self else { return UITableViewCell() }
            
            if item.medicineCards.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: SymptomLogCell.identifier, for: indexPath) as? SymptomLogCell
                guard let cell else { return UITableViewCell() }

                cell.setAttributes(item: item)
                cell.delegate = self
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: MedicineLogCell.identifier, for: indexPath) as? MedicineLogCell
                guard let cell else { return UITableViewCell() }

                cell.setAttributes(item: item)
                cell.delegate = self
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
    
    
    func removeTask(item: any EditButtonCellModel) {
        switch item {
        case let item as LogData:
            presentAlert(
                title: String(localized: "알림"),
                message: String(localized: "기록을 삭제할까요?"),
                acceptTitle: String(localized: "삭제"),
                acceptTask: { [weak self] in
                    LogDataManager.shared.delete(target: item)
                    self?.logVM.input.reloadSectionData.onNext(())
                })
            
        default:
            print("오류발생", #function)
            return
        }
    }
}



#Preview {
    TabBarVC()
}
