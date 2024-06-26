//
//  ChapelInfoView.swift
//  Haram
//
//  Created by 이건준 on 2023/05/06.
//

import UIKit
  
import SnapKit
import SkeletonView
import Then

enum ChapelViewType: CaseIterable {
  case attendance
  case remain
  case tardy
  
  var title: String {
    switch self {
    case .attendance:
      return "출석"
    case .remain:
      return "남은일수"
    case .tardy:
      return "지각"
    }
  }
}

struct ChapelInfoViewModel {
  let attendanceDays: String
  let remainDays: String
  let lateDays: String
}

final class ChapelView: UIView {
  
  private let type: ChapelViewType
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex9F9FA4
    $0.font = .regular16
    $0.textAlignment = .center
  }
  
  private let dayLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold18
    $0.textAlignment = .center
  }
  
  init(type: ChapelViewType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    titleLabel.text = type.title
    [titleLabel, dayLabel].forEach {
      $0.isSkeletonable = true
      addSubview($0)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(19)
    }
    
    dayLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(3)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: String) {
    dayLabel.text = "\(model)일"
  }
}

final class ChapelInfoView: UIView {
  private let contentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 36
    $0.distribution = .equalSpacing
  }
  
  private let attendanceView = ChapelView(type: .attendance)
  private let remainView = ChapelView(type: .remain)
  private let tardyView = ChapelView(type: .tardy)
  
  private let lineView = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private let lineView1 = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentStackView.isSkeletonable = true
    
    addSubview(contentStackView)
    [attendanceView, lineView, remainView, lineView1, tardyView].forEach {
      $0.isSkeletonable = true
      contentStackView.addArrangedSubview($0)
    }
    
    contentStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.width.equalTo(1)
    }
    
    lineView1.snp.makeConstraints {
      $0.width.equalTo(1)
    }
  }
  
  func configureUI(with model: ChapelInfoViewModel) {
    attendanceView.configureUI(with: model.attendanceDays)
    remainView.configureUI(with: model.remainDays)
    tardyView.configureUI(with: model.lateDays)
  }
}
