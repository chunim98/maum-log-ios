//
//  TabBarVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/8/24.
//

import UIKit

import SnapKit

final class TabBarVC: UITabBarController {
    
    // MARK: Components
    
    private let tabBarBackground = OutlinedView(strokeWidth: 0.5)
  
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuWhite // 탭바 뒤 배경색
        
        setAutoLayout()
        setUpTabBar()
        checkSettings()
    }
    
    // MARK: Layout
    
    func setAutoLayout() {
        tabBar.insertSubview(tabBarBackground, at: 0) // tabBar 서브뷰 중 제일 아래 레이어에 삽입
        tabBarBackground.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: Configure
    
    func setUpTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground() // 투명도가 있는 배경을 내맘대로 설정
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        // 탭바 아이템 색 관련
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.chuBlack]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.chuLightGray]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.chuBlack
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.chuLightGray
        
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: Methods
    
    func checkSettings() {
        if SettingValuesStorage.shared.showLogVCAtStart { self.selectedIndex = 1 }
    }
}

#Preview {
    TabBarVC()
}
