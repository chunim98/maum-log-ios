//
//  MedicineLogCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MedicineLogCell: UITableViewCell {
    
    static let identifier = "MedicineLogCell"
    let bag = DisposeBag()
    var item: (any EditButtonCellModel)?
    
    private var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        return formatter
    }()
    
    private let cardData = BehaviorSubject<[MedicineCardData]>(value: [])
    let itemToRemove = PublishSubject<EditButtonCellModel>()

    // MARK: - Components
    let mainHStack = {
        let sv = UIStackView()
        sv.spacing = 10
        sv.alignment = .center
        return sv
    }()
    
    let dateLabel = {
        let label = UILabel()
        label.text = "오전 12:99"
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    let takeMedicineVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.backgroundColor = .chuBlack
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 0, leading: 5, bottom: 0, trailing: 5)
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 10
        return sv
    }()
    
    let takeMedicineLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = String(localized: "복용")
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .chuWhite
        return label
    }()
    
    let deleteButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "multiply.circle.fill")?.applyingSymbolConfiguration(.init(pointSize: 15))
        config.baseForegroundColor = .gray
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        button.isHidden = false
        return button
    }()
    
    let infoCardCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        cv.register(MedicineCardCell.self, forCellWithReuseIdentifier: MedicineCardCell.identifier)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.setSinglelineLayout(spacing: 5, width: 118, height: 30)
        return cv
    }()
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setAutoLayout()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 콘텐츠 뷰 설정
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0))
        contentView.backgroundColor = .chuWhite
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    // MARK: - Layout
    private func setAutoLayout(){
        contentView.addSubview(mainHStack)
        mainHStack.addArrangedSubview(dateLabel)
        mainHStack.addArrangedSubview(takeMedicineVStack)
        mainHStack.addArrangedSubview(infoCardCV)
        mainHStack.addArrangedSubview(deleteButton)
        takeMedicineVStack.addArrangedSubview(takeMedicineLabel)

        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)) }
        dateLabel.snp.makeConstraints { $0.width.equalTo(65) }
        infoCardCV.snp.makeConstraints { $0.height.equalTo(30) }
        takeMedicineVStack.snp.makeConstraints { $0.height.equalTo(26) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        // 약 카드 데이터 바인딩
        cardData
            .bind(to: infoCardCV.rx.items(cellIdentifier: MedicineCardCell.identifier, cellType: MedicineCardCell.self)) { index, item, cell in
                cell.configure(item: item)
            }
            .disposed(by: bag)

        // 삭제 요청과 함께 아이템 전송
        deleteButton
            .rx.tap
            .bind(with: self) { owner, _ in
                guard let item = owner.item else { return }
                owner.itemToRemove.onNext(item)
            }
            .disposed(by: bag)
    }
    
    func configure(item: EditButtonCellModel) {
        guard let item = item as? LogData else { return }
        guard !(item.medicineCards.isEmpty) else { return }
        self.item = item

        cardData.onNext(item.medicineCards)
        
        dateLabel.text = formatter.string(from: item.date)
        deleteButton.isHidden = !(item.isEditMode)
    }
    
}

#Preview(traits: .fixedLayout(width: 400, height: 100)) {
    MedicineLogCell()
}

