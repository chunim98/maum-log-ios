//
//  UICollectionView+.swift
//  MaumLog
//
//  Created by 신정욱 on 12/2/24.
//


import UIKit

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