//
//  LibraryDetailMainView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/21.
//

import UIKit

import Kingfisher
import SnapKit
import SkeletonView
import Then

struct LibraryDetailMainViewModel {
  let bookImageURL: URL?
  let title: String
  let subTitle: String
  
  init(response: RequestBookInfoResponse) {
    bookImageURL = URL(string: response.thumbnailImage)
    title = response.bookTitle
    subTitle = response.publisher
  }
}

final class LibraryDetailMainView: UIView {
  
  var mainImage: UIImage? {
    bookImageView.image
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.alignment = .center
    $0.backgroundColor = .clear
    $0.distribution = .fill
  }
  
  private let outerView = UIView().then {
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.4
    $0.layer.shadowRadius = 10
    $0.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    $0.layer.backgroundColor = UIColor.clear.cgColor
  }
  
  private let bookImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.backgroundColor = UIColor.clear.cgColor
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .white
    $0.contentMode = .scaleAspectFill
    $0.isUserInteractionEnabled = true
  }
  
  let button = UIButton()
  
  private let titleLabel = UILabel().then {
    $0.font = .bold22
    $0.textColor = .black
    $0.numberOfLines = 3
    $0.lineBreakMode = .byTruncatingTail
    $0.skeletonTextNumberOfLines = 2
    $0.textAlignment = .center
  }
  
  private let subLabel = UILabel().then {
    $0.font = .regular16
    $0.textColor = .black
    $0.skeletonTextNumberOfLines = 1
    $0.textAlignment = .center
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    backgroundColor = .clear
    
    _ = [containerView, outerView, titleLabel, subLabel].map { $0.isSkeletonable = true }
    
    outerView.skeletonCornerRadius = 10
    
    addSubview(containerView)
    _ = [outerView, titleLabel, subLabel].map { containerView.addArrangedSubview($0) }
    outerView.addSubview(bookImageView)
    bookImageView.addSubview(button)
    
    containerView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(15)
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    outerView.snp.makeConstraints {
      $0.height.equalTo(210)
      $0.width.equalTo(150)
    }
    
    bookImageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    button.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    [titleLabel, subLabel].forEach {
      $0.snp.makeConstraints {
        $0.directionalHorizontalEdges.equalToSuperview()
      }
    }
    
    containerView.setCustomSpacing(31, after: subLabel)
  }
  
  func configureUI(with model: LibraryDetailMainViewModel) {
    bookImageView.kf.setImage(with: model.bookImageURL, placeholder: UIImage(systemName: "book"))
    titleLabel.text = model.title
    subLabel.text = model.subTitle
  }
}


