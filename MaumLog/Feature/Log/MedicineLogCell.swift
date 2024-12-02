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

final class MedicineLogCell: UITableViewCell, EditButtonCellType {
    
    static let identifier = "MedicineLogCell"
    private let bag = DisposeBag()
    var delegate: (any EditButtonCellDelegate)?
    var item: (any EditButtonCellModel)?
    
    private let CVCellData = BehaviorSubject<[MedicineCardData]>(value: [])
    private var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        return formatter
    }()
    
    //MARK: - 컴포넌트
    let overallSV = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fill
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
    
    let takeMedicineSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = .zero
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
    
    //MARK: - 라이프 사이클
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
    
    //MARK: - 오토레이아웃
    private func setAutoLayout(){
        contentView.addSubview(overallSV)
        overallSV.addArrangedSubview(dateLabel)
        overallSV.addArrangedSubview(takeMedicineSV)
        overallSV.addArrangedSubview(infoCardCV)
        overallSV.addArrangedSubview(deleteButton)
        
        takeMedicineSV.addArrangedSubview(takeMedicineLabel)

        overallSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        }
        
        dateLabel.snp.makeConstraints { make in
            make.width.equalTo(65)
        }
        infoCardCV.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        takeMedicineSV.snp.makeConstraints { make in
            make.height.equalTo(26)
        }
    }
    
    //MARK: - 바인드
    private func setBinding() {
        CVCellData
            .bind(to: infoCardCV.rx.items(cellIdentifier: MedicineCardCell.identifier, cellType: MedicineCardCell.self)) { index, item, cell in
                cell.setAttributes(item: item)
            }
            .disposed(by: bag)
        
        deleteButton
            .rx.tap
            .bind(onNext: { [weak self] in
                guard let self, let item else { return }
                delegate?.removeTask(item: item)
            })
            .disposed(by: bag)
    }
    
    func setAttributes(item: EditButtonCellModel) {
        guard let item = item as? LogData else { return }
        guard !(item.medicineCards.isEmpty) else { return }
        self.item = item

        CVCellData.onNext(item.medicineCards)
        
        dateLabel.text = formatter.string(from: item.date)
        deleteButton.isHidden = !(item.isEditMode)
    }
    
}

#Preview(traits: .fixedLayout(width: 400, height: 100)) {
    MedicineLogCell()
}

