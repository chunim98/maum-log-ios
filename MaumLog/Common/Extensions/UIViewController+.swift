//
//  UIViewController+.swift
//  MaumLog
//
//  Created by 신정욱 on 12/2/24.
//


import UIKit

extension UIViewController {
    func presentAlert(
        title: String,
        message: String,
        acceptTitle: String = String(localized: "확인"),
        cancelTitle: String = String(localized: "취소"),
        acceptTask: (() -> Void)? = nil,
        cancelTask: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let accept = UIAlertAction(title: acceptTitle, style: .default) { _ in acceptTask?() }
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel) { _ in cancelTask?() }
        
        alert.addAction(accept)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAcceptAlert(
        title: String,
        message: String,
        acceptTitle: String = String(localized: "확인"),
        acceptTask: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let accept = UIAlertAction(title: acceptTitle, style: .default) { _ in acceptTask?() }
        
        alert.addAction(accept)
            
        self.present(alert, animated: true, completion: nil)
    }

    //네비게이션 바 구성, 스크롤 시에도 색이 변하지 않음
    func setNavigationBar(
        leftBarButtonItems: [UIBarButtonItem]? = nil,
        rightBarButtonItems: [UIBarButtonItem]? = nil,
        title: String? = nil
    ){
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .chuIvory
        navigationBarAppearance.shadowColor = .clear // 그림자 없애기
        
        if let title { // 타이틀 설정
            navigationBarAppearance.titleTextAttributes = [.foregroundColor : UIColor.chuBlack] // 타이틀 색깔
            navigationController?.navigationBar.tintColor = .chuBlack
            self.title = title
        }
        if let leftBarButtonItems {
            navigationItem.leftBarButtonItems = leftBarButtonItems
        }
        if let rightBarButtonItems {
            navigationItem.rightBarButtonItems = rightBarButtonItems
        }
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
}
