//
//  TabBarVC.swift
//  MaumLog
//
//  Created by 신정욱 on 8/8/24.
//

import UIKit
import SnapKit

// 뷰컨 상속했으니 아무튼 뷰컨임
final class TabBarVC: UITabBarController {
    
    //MARK: - 컴포넌트
    let tabBarBackground = OutlinedView(strokeWidth: .chuStrokeWidth)
  
    //MARK: - 라이프 사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuWhite // 탭바 뒤 배경색
        
        setAutoLayout()
        setUpTabBar()
        checkSettings()
    }
    
    //MARK: - 탭바 만들기
    func setUpTabBar() {
        // 뷰 추가
        let vc1 = UINavigationController(rootViewController: HomeVC()) // UINavigationController로 감싸야 네비게이션 바, push등 사용가능
        let vc2 = UINavigationController(rootViewController: LogVC())
        
        // 탭바 이름들 설정
        vc1.title = String(localized: "대시보드")
        vc2.title = String(localized: "기록")
        
        // 이 시점에 탭바 아이템이 만들어짐
        setViewControllers([vc1, vc2], animated: true)
        
        // 탭바 이미지 설정, setViewControllers()호출 뒤에 설정해야만 함
        guard let items = tabBar.items else { return }
        items[0].image = UIImage(named: "dashboard")?.resizeImage(newWidth: 22)
        items[1].image = UIImage(named: "log")?.resizeImage(newWidth: 20)

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
    
    //MARK: - 오토레이아웃
    func setAutoLayout() {
        // tabBar 서브뷰 중 제일 아래 레이어에 삽입
        tabBar.insertSubview(tabBarBackground, at: 0)
        
        tabBarBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func checkSettings() {
        if SettingValuesStorage.shared.showLogVCAtStart {
            self.selectedIndex = 1
        }
    }
    
}

#Preview {
    TabBarVC()
}
