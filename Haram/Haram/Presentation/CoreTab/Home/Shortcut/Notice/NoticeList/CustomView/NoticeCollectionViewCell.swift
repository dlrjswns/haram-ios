//
//  NoticeCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/05/28.
//

import UIKit

import SnapKit
import SkeletonView
import Then

struct NoticeCollectionViewCellModel {
  let title: String
  let description: String
  let noticeType: [String]
  let path: String
}

final class NoticeCollectionViewCell: UICollectionViewCell, ReusableView {
  
  private let entireView = UIView().then {
    $0.backgroundColor = .hexF8F8F8
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  private let mainLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex1A1E27
  }
  
  private let subLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .hex1A1E27
  }
  
  private let typeStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.backgroundColor = .clear
    $0.spacing = 5
  }
  
  private let indicatorButton = UIButton().then {
    $0.setImage(UIImage(named: "darkIndicator"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    mainLabel.text = nil
    subLabel.text = nil
    _ = typeStackView.subviews.map { $0.removeFromSuperview() }
  }
  
  private func configureUI() {
    isSkeletonable = true
    skeletonCornerRadius = 10
    
    contentView.backgroundColor = .clear
    
    contentView.addSubview(entireView)
    entireView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    [mainLabel, subLabel, typeStackView, indicatorButton].forEach { entireView.addSubview($0) }
    
    mainLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(12)
      $0.trailing.lessThanOrEqualToSuperview().inset(20)
    }
    
    subLabel.snp.makeConstraints {
      $0.top.equalTo(mainLabel.snp.bottom).offset(3)
      $0.leading.equalTo(mainLabel)
      $0.trailing.lessThanOrEqualTo(indicatorButton.snp.leading)
      $0.bottom.trailing.lessThanOrEqualToSuperview()
    }
    
    typeStackView.snp.makeConstraints {
      $0.top.equalTo(subLabel.snp.bottom).offset(3)
      $0.leading.equalTo(subLabel)
      $0.bottom.equalToSuperview().inset(9)
      $0.trailing.lessThanOrEqualToSuperview().inset(12)
    }
    
    indicatorButton.snp.makeConstraints {
      $0.width.equalTo(6)
      $0.height.equalTo(12)
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(14)
    }
  }
  
  func configureUI(with model: NoticeCollectionViewCellModel) {
    mainLabel.text = model.title
    subLabel.text = model.description
    
    model.noticeType.forEach { type in
      let paddingLabel = PaddingLabel(withInsets: 2, 3, 8, 9).then {
        $0.font = .regular11
        $0.textColor = .hex1A1E27
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 5
        $0.backgroundColor = .hexD8D8DA
      }
      paddingLabel.text = type
      paddingLabel.snp.makeConstraints {
        $0.height.equalTo(19)
      }
      typeStackView.addArrangedSubview(paddingLabel)
    }
  }
  
  func setHighlighted(isHighlighted: Bool) {
    if isHighlighted {
      let pressedDownTransform = CGAffineTransform(scaleX: 0.98, y: 0.98)
      UIView.transition(with: entireView, duration: 0.1) {
        self.entireView.backgroundColor = .lightGray
      }
    } else {
      UIView.transition(with: entireView, duration: 0.1) {
        self.entireView.backgroundColor = .hexF8F8F8
      }
    }
  }
}
