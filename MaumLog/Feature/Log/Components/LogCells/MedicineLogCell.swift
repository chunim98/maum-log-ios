//
//  MedicineLogCell.swift
//  MaumLog
//
//  Created by 신정욱 on 8/26/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class MedicineLogCell: UITableViewCell {
    
    // MARK: Properties

    static let identifier = "MedicineLogCell"
    private var bag = DisposeBag()

    // MARK: Components
    
    private let mainHStack = {
        let sv = UIStackView()
        sv.alignment = .center
        sv.spacing = 10
        return sv
    }()
    
    private let dateLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = "오전 12:99" // temp
        label.textColor = .gray
        return label
    }()
    
    private let intakeVStack = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = .init(horizontal: 5)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.backgroundColor = .chuBlack
        sv.layer.cornerRadius = 10
        sv.clipsToBounds = true
        sv.axis = .vertical
        return sv
    }()
    
    private let intakeLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .chuWhite
        label.text = "복용"
        return label
    }()
    
    private let deleteImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "multiply.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.gray)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let infoCardCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(
            MedicineCardCell.self,
            forCellWithReuseIdentifier: MedicineCardCell.identifier
        )
        cv.setSinglelineLayout(spacing: 5, width: 118, height: 30)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    // MARK:  Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setAutoLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: .init(bottom: 1))
        contentView.backgroundColor = .chuWhite
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        deleteImageView.isHidden = true
        dateLabel.text = ""
        bag = DisposeBag() // 재사용 시, 델리게이트 중복 등록 오류 방지
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout
    
    private func setAutoLayout() {
        contentView.addSubview(mainHStack)
        mainHStack.addArrangedSubview(dateLabel)
        mainHStack.addArrangedSubview(intakeVStack)
        mainHStack.addArrangedSubview(infoCardCV)
        mainHStack.addArrangedSubview(deleteImageView)
        intakeVStack.addArrangedSubview(intakeLabel)

        mainHStack.snp.makeConstraints {
            let inset = UIEdgeInsets(horizontal: 10, vertical: 5)
            $0.edges.equalToSuperview().inset(inset)
        }
        dateLabel.snp.makeConstraints { $0.width.equalTo(65) }
        infoCardCV.snp.makeConstraints { $0.height.equalTo(30) }
        intakeVStack.snp.makeConstraints { $0.height.equalTo(26) }
    }
    
    // MARK: Configure
    
    func configure(_ data: EditButtonCellModel) {
        guard
            let data = data as? LogData,
            !data.medicineCards.isEmpty
        else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        
        dateLabel.text = formatter.string(from: data.date)
        deleteImageView.isHidden = !data.isEditMode
        
        // 복욕 카드 데이터 바인딩
        Observable.just(data.medicineCards)
            .bind(to: infoCardCV.rx.items(
                cellIdentifier: MedicineCardCell.identifier,
                cellType: MedicineCardCell.self
            )) { index, data, cell in
                cell.configure(data)
            }
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 100)) {
    MedicineLogCell()
}

