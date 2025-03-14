//
//  ColorPaletteView.swift
//  MaumLog
//
//  Created by 신정욱 on 3/15/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class ColorPaletteView: UIView {
    
    // MARK: Properties
    
    private let bag = DisposeBag()
    private let once = OnlyOnce()

    // MARK: Components
    
    private let borderView = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = .init(edges: 10)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.backgroundColor = .chuWhite
        sv.layer.cornerRadius = 25
        sv.clipsToBounds = true
        return sv
    }()
    
    fileprivate let paletteCV: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(
            ColorPaletteCell.self,
            forCellWithReuseIdentifier: ColorPaletteCell.identifier
        )
        cv.showsVerticalScrollIndicator = false // 스크롤 바 숨기기
        cv.backgroundColor = .chuWhite
        cv.layer.cornerRadius = 15
        cv.clipsToBounds = true
        return cv
    }()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
        setBinding()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        once.excute { setPaletteCVLayout() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setPaletteCVLayout() {
        self.layoutIfNeeded()
        paletteCV.setMultilineLayout(spacing: 15, itemCount: 6, itemHeight: 50)
    }
    
    private func setAutoLayout() {
        self.addSubview(borderView)
        borderView.addArrangedSubview(paletteCV)
        borderView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: Binding
    
    private func setBinding() {
        let colorPalette = [
            0x6d6a74, 0x8e8a95, 0xb2b8c0, 0x6a5976, 0xd1b8b4, 0xd4c6c3,
            0xd6c9c6, 0x9c7f8a, 0xdca46d, 0xc48b6d, 0x8d8a95, 0x7d676a,
            0x5f5a64, 0x8c7d8a, 0xb1a5b1, 0xb9b5bf, 0xd2b5b5, 0xdfc7c4,
            0xd4b8a6, 0x8e7d7b, 0x7b6d71, 0xa28d8d, 0x7f6f7b, 0x6b5a6b,
            0x9d7a73, 0xb4a79b, 0x6b6f43, 0x8a8c5e, 0x9a9e71, 0xb4b86e,
        ]
        
        // 컬러 팔레트 데이터 바인딩
        Observable.just(colorPalette)
            .bind(to: paletteCV.rx.items(
                cellIdentifier: ColorPaletteCell.identifier,
                cellType: ColorPaletteCell.self
            )) { index, hex, cell in
                cell.configure(hex)
            }
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 400)) {
    ColorPaletteView()
}

// MARK: - Reactive

extension Reactive where Base: ColorPaletteView {
    var selectedColor: Observable<UIColor> {
        base.paletteCV.rx.modelSelected(Int.self).asObservable()
            .map { $0.toUIColor }
    }
}
