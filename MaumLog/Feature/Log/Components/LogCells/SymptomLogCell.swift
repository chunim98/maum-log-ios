//
//  SymptomLogCell.swift
//  MaumLog
//
//  Created by 신정욱 on 7/30/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class SymptomLogCell: UITableViewCell {
    
    // MARK: Properties
    
    static let identifier = "SymptomLogCell"
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
    
    private let deleteImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "multiply.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.gray)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let infoCardCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        cv.register(RateCardCell.self, forCellWithReuseIdentifier: RateCardCell.identifier)
        cv.setSinglelineLayout(spacing: 5, width: 100, height: 60)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    // MARK: Life Cycle
    
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
        dateLabel.text = ""
        deleteImageView.isHidden = true
        bag = DisposeBag() // 재사용 시, 델리게이트 중복 등록 오류 방지
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout
    
    private func setAutoLayout() {
        contentView.addSubview(mainHStack)
        mainHStack.addArrangedSubview(dateLabel)
        mainHStack.addArrangedSubview(infoCardCV)
        mainHStack.addArrangedSubview(deleteImageView)

        mainHStack.snp.makeConstraints {
            let inset = UIEdgeInsets(horizontal: 10, vertical: 5)
            $0.edges.equalToSuperview().inset(inset)
        }
        dateLabel.snp.makeConstraints { $0.width.equalTo(65) }
        infoCardCV.snp.makeConstraints { $0.height.equalTo(60) }
    }
    
    // MARK: Configure
    
    func configure(_ data: EditButtonCellModel) {
        guard
            let data = data as? LogData,
            !data.symptomCards.isEmpty
        else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        
        dateLabel.text = formatter.string(from: data.date)
        deleteImageView.isHidden = !data.isEditMode
        
        // 증상 카드 데이터 바인딩
        Observable.just(data.symptomCards)
            .bind(to: infoCardCV.rx.items(
                cellIdentifier: RateCardCell.identifier,
                cellType: RateCardCell.self
            )) { index, data, cell in
                cell.configure(data)
            }
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 100)) {
    SymptomLogCell()
}
