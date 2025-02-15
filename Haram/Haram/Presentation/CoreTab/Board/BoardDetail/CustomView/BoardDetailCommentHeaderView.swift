//
//  BoardDetailCommentHeaderView.swift
//  Haram
//
//  Created by 이건준 on 2023/09/20.
//

import UIKit

import SnapKit
import SkeletonView
import Then

final class BoardDetailCommentHeaderView: UICollectionReusableView, ReusableView {
  
  private let commentTitleLabel = UILabel().then {
    $0.font = .bold16
    $0.textColor = .black
    $0.text = "댓글"
    $0.isSkeletonable = true
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
    
    addSubview(commentTitleLabel)
    commentTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(13.5)
      $0.leading.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
      $0.bottom.equalToSuperview().inset(17)
    }
  }
}
