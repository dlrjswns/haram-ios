//
//  StudyListCollectionViewCell.swift
//  Haram
//
//  Created by 이건준 on 2023/08/17.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct StudyListCollectionViewCellModel: Hashable {
  let roomSeq: Int
  let title: String
  let description: String
  let imageURL: URL?
  private let identifier = UUID()
  
  init(rothemRoom: RothemRoom) {
    roomSeq = rothemRoom.roomSeq
    title = rothemRoom.roomName
    description = rothemRoom.roomExplanation
    imageURL = URL(string: rothemRoom.thumbnailImage)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}

final class StudyListCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "StudyListCollectionViewCell"
  
  private let studyTitleLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .hex1A1E27
    $0.numberOfLines = 1
  }
  
  private let studyDescriptionLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .regular14
    $0.numberOfLines = 3
    $0.lineBreakMode = .byTruncatingTail
  }
  
  private let studyImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    
    [studyTitleLabel, studyDescriptionLabel, studyImageView].forEach {
      $0.isSkeletonable = true
      contentView.addSubview($0)
    }
    
    studyImageView.snp.makeConstraints {
      $0.directionalVerticalEdges.trailing.equalToSuperview()
      $0.size.equalTo(98)
    }
    
    studyTitleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
      $0.trailing.lessThanOrEqualTo(studyImageView.snp.leading)
    }
    
    studyDescriptionLabel.snp.makeConstraints {
      $0.top.equalTo(studyTitleLabel.snp.bottom).offset(6)
      $0.leading.equalTo(studyTitleLabel)
      $0.bottom.lessThanOrEqualToSuperview()
      $0.trailing.lessThanOrEqualTo(studyImageView.snp.leading).offset(-15)
    }
  }
  
  func configureUI(with model: StudyListCollectionViewCellModel) {
    
    studyTitleLabel.text = model.title
    studyDescriptionLabel.addLineSpacing(lineSpacing: 3, string: model.description)
    studyImageView.kf.setImage(with: model.imageURL)
  }
}
