//
//  Utils.swift
//  MaumLog
//
//  Created by 신정욱 on 7/28/24.
//

import UIKit

// MARK: - UIColor
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xff) >> 0) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    static var chuWhite: UIColor {
        UIColor.init(hex: 0xfbf9f7)
    }
    
    static var chuIvory: UIColor {
        UIColor.init(hex: 0xefebeb)
    }
    
    static var chuBlack: UIColor {
        UIColor.init(hex: 0x464044)
    }
    
    static var chuLightGray: UIColor {
        UIColor.init(hex: 0xd6d4d2)
    }
    
    static var chuBadRate: UIColor {
        UIColor.init(hex: 0xd49773)
    }
    
    static var chuOtherRate: UIColor {
        UIColor.chuColorPalette[2]
    }
    
    static var chuColorPalette: [UIColor] {
        let array: [UIColor] = [
            .init(hex: 0xd4b8a6),
            .init(hex: 0x8e7d7b),
            .init(hex: 0x7b6d71),
            .init(hex: 0xa28d8d),
            .init(hex: 0x7f6f7b),
            .init(hex: 0x6b5a6b),
            .init(hex: 0x9d7a73),
            .init(hex: 0xb4a79b),
            .init(hex: 0x6b6f43),
            .init(hex: 0x8a8c5e),
            .init(hex: 0x9a9e71),
            .init(hex: 0xb4b86e)
        ]
        return array
    }
    
    static let chuTint = UIColor.chuColorPalette.randomElement()
    
    var toHexInt: Int {
        // CGColor를 sRGB로 변환
        guard let cgColorInRGB = cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil),
              let components = cgColorInRGB.components else {
            return 0x0 // 변환 실패 시 기본값
        }
        // RGB 구성 요소 추출
        let r = components[0]
        let g = components[1]
        let b = (components.count > 2 ? components[2] : g) // 회색조일 경우 g 사용
        let a = cgColor.alpha
        // RGB 값을 8비트 정수로 변환
        let red = Int(r * 255)
        let green = Int(g * 255)
        let blue = Int(b * 255)
        // 16진수 Int로 결합
        var hexInt = (red << 16) | (green << 8) | blue
        // 알파 값이 1이 아닐 경우 알파 포함
        if a < 1 {
            let alpha = Int(a * 255)
            hexInt = (hexInt << 8) | alpha
        }
        // 결과 반환
        return hexInt
    }
}

// MARK: - AttributeContainer
extension AttributeContainer {
    static func chuBoldTitle(ofSize size: CGFloat) -> AttributeContainer {
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: size)
        return container
    }
    
    static func chuTitle(ofSize size: CGFloat) -> AttributeContainer {
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: size)
        return container
    }
}

// MARK: - UIViewController
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
            navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.chuBlack] // 타이틀 색깔
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

// MARK: - UICollectionView
extension UICollectionView {
    func setMultilineLayout(spacing: CGFloat, itemCount: CGFloat, itemHeight: CGFloat) {
        var totalInterSpace: CGFloat { (itemCount - 1) * spacing }
        let itemSize = CGSize(width: (self.bounds.width - totalInterSpace) / itemCount, height: itemHeight)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical // 스크롤 방향
        flowLayout.itemSize = itemSize
        flowLayout.minimumInteritemSpacing = spacing // 스크롤 방향 기준 아이템 간 간격
        flowLayout.minimumLineSpacing = spacing // 스크롤 방향 기준 열 간격
        
        self.collectionViewLayout = flowLayout
    }
    
    func setMultilineLayout(spacing: CGFloat, itemCount: CGFloat) {
        var totalInterSpace: CGFloat { (itemCount - 1) * spacing }
        let itemSize = CGSize(
            width: (self.bounds.width - totalInterSpace) / itemCount,
            height: (self.bounds.width - totalInterSpace) / itemCount)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical // 스크롤 방향
        flowLayout.itemSize = itemSize
        flowLayout.minimumInteritemSpacing = spacing // 스크롤 방향 기준 아이템 간 간격
        flowLayout.minimumLineSpacing = spacing // 스크롤 방향 기준 열 간격
        
        self.collectionViewLayout = flowLayout
    }
    
    func setSinglelineLayout(spacing: CGFloat, width: CGFloat, height: CGFloat) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal // 스크롤 방향
        flowLayout.itemSize = CGSize(width: width, height: height)
        flowLayout.minimumInteritemSpacing = .zero // 스크롤 방향 기준 아이템 간 간격
        flowLayout.minimumLineSpacing = spacing // 스크롤 방향 기준 열 간격
        
        self.collectionViewLayout = flowLayout
    }

}

// MARK: - DateFormatter
extension DateFormatter {
    static var forSort: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    static var forHeader: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        return formatter
    }
}

// MARK: - Int
extension Int {
    var toNegativeName: String {
        switch self {
        case 0:
            return String(localized: "없음")
        case 1:
            return String(localized: "매우약함")
        case 2:
            return String(localized: "약함")
        case 3:
            return String(localized: "보통")
        case 4:
            return String(localized: "심함")
        case 5:
            return String(localized: "매우심함")
        default:
            return "error"
        }
    }
    
    var toOtherName: String {
        switch self {
        case 0:
            return String(localized: "없음")
        case 1:
            return String(localized: "매우약함")
        case 2:
            return String(localized: "약함")
        case 3:
            return String(localized: "보통")
        case 4:
            return String(localized: "강함")
        case 5:
            return String(localized: "매우강함")
        default:
            return "error"
        }
    }

    var toRateColor: UIColor {
        switch self {
        case 0:
            return .chuIvory
        case 1:
            return .init(hex: 0xfdc15a)
        case 2:
            return .init(hex: 0xfdb25e)
        case 3:
            return .init(hex: 0xfda463)
        case 4:
            return .init(hex: 0xfd9669)
        case 5:
            return .init(hex: 0xfd856e)
        default:
            return .clear
        }
    }
    
    var toRateAlpha: CGFloat {
        switch self {
        case 0:
            return 0.5
        case 1:
            return 0.6
        case 2:
            return 0.7
        case 3:
            return 0.8
        case 4:
            return 0.9
        case 5:
            return 1.0
        default:
            return 0
        }
    }
    
    var toUIColor: UIColor {
        UIColor.init(hex: self)
    }
    
    var to16: Int16 {
        Int16(self)
    }
    
    var to32: Int32 {
        Int32(self)
    }
}

extension Int16 {
    var toInt: Int {
        Int(self)
    }
}

extension Int32 {
    var toInt: Int {
        Int(self)
    }
}

// MARK: - Array
extension Array where Element == Int16 {
    var toIntArr: [Int] {
        self.map{ Int($0) }
    }
}

extension Array where Element == Int32 {
    var toIntArr: [Int] {
        self.map{ Int($0) }
    }
}

extension Array where Element == Int {
    var to16Arr: [Int16] {
        self.map{ Int16($0) }
    }
    var to32Arr: [Int32] {
        self.map{ Int32($0) }
    }
}

// MARK: - CGFloat
extension CGFloat {
    // static이면 저장속성이라도 extension에 구현가능
    static let chuSpace: CGFloat = 15
    static let chuRadius: CGFloat = 15
    static let chuStrokeWidth: CGFloat = 0.5
    static let chuHeight: CGFloat = 50
    var reverse: CGFloat { self * -1 }
}

// MARK: - UIImage
extension UIImage {
    // 비율 유지하며 이미지 리사이즈
    func resizeImage(newWidth: CGFloat) -> UIImage {
        // 이미지 비율 구하는 공식
        // (original height / original width) x new width = new height
        
        let newHeight = (self.size.height / self.size.width) * newWidth
        
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
}



