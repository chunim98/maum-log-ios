//
//  SettingsVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/9/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class SettingsVC: UIViewController {
    
    private let settingsVM = SettingsVM()
    private let bag = DisposeBag()
    weak var coordinator: SettingsCoordinator?
    
    // MARK: - Components
    let settingsTV: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.register(ButtonTypeCell.self, forCellReuseIdentifier: ButtonTypeCell.identifier)
        tv.register(ToggleTypeCell.self, forCellReuseIdentifier: ToggleTypeCell.identifier)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.clipsToBounds = false
        return tv
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuIvory
        settingsTV.dataSource = self
        
        setAutoLayout()
        setNavigationBar(title: String(localized: "설정"))
    }
    
    // 화면이 사라질 때 코디네이터의 deinit은 따로 처리해야 함
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        coordinator?.finish()
    }
    
    // MARK: - Layout
    func setAutoLayout() {
        view.addSubview(settingsTV)
        settingsTV.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
    }
}

// MARK: - UITableViewDataSource
extension SettingsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        settingsVM.sectionHeader.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        settingsVM.sectionHeader[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // 기록
            return 1 // 나중에 셀 타입별로 모델이라도 만들어서 관리해야 할듯
        case 1: // 기타
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 효율적이지는 않지만 셀 하나하나를 다르게 설정하기 위해 dequeue를 쓰지 않음
        switch indexPath.section {
        case 0: // 기록
            if indexPath.row == 0 {
                let cell = ButtonTypeCell()
                cell.configure(
                    title: String(localized: "기록 초기화"),
                    caption: String(localized: "지금까지의 모든 기록을 삭제합니다.\n이 작업은 취소할 수 없으니 주의하세요!"),
                    buttonTitle: String(localized: "초기화"), 
                    buttonColor: .init(hex: 0xb83b3d))
                cell.buttonTask = { [weak self] in
                    guard let self else { return }
                    settingsVM.deleteAllLog(view: self)
                }
                return cell
            } else {
                return UITableViewCell()
            }
            
        case 1: // 기타
            if indexPath.row == 0 {
                let cell = ToggleTypeCell()
                cell.configure(
                    title: String(localized: "실행 시 기록 탭 보기"),
                    caption: String(localized: "실행 시 기본 화면을 기록 탭으로 변경합니다."),
                    isOn: SettingValuesStorage.shared.showLogVCAtStart)
                cell.toggleTask = { SettingValuesStorage.shared.showLogVCAtStart = $0 }
                return cell
            } else {
                return UITableViewCell()
            }
            
        default:
            return UITableViewCell()
        }
    }
}


#Preview {
    SettingsVC()
}
