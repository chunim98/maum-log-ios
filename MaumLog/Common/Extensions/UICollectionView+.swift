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
    
    func setMultilineLayout(
        spacing: CGFloat,
        itemCount: CGFloat,
        itemSize hopeSize: CGSize,
        sectionInset: UIEdgeInsets = .zero
    ) {
        let totalInterSpace = (itemCount-1) * spacing
        let insetWidth = sectionInset.left + sectionInset.right
        let insetHeight = sectionInset.top + sectionInset.bottom

        // 컬렉션 뷰 크기 기준으로 계산한, 실제 사용 가능한 셀 사이즈
        let validSize = CGSize(
            width: (self.bounds.width-totalInterSpace-insetWidth) / itemCount,
            height: (self.bounds.height-totalInterSpace-insetHeight) / itemCount
        )
        
        // 넓이를 기준으로 배율 구하기
        let scale = validSize.width / hopeSize.width
        
        let scaledSize = CGSize(
            width: hopeSize.width * scale,
            height: hopeSize.height * scale
        )
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical // 스크롤 방향
        flowLayout.itemSize = scaledSize
        flowLayout.minimumInteritemSpacing = spacing // 스크롤 방향 기준 아이템 간 간격
        flowLayout.minimumLineSpacing = spacing // 스크롤 방향 기준 열 간격
        flowLayout.sectionInset = sectionInset
        
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
