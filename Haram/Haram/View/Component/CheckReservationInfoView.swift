//
//  CheckReservationInfoView.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol CheckReservationInfoViewDelegate: AnyObject {
  func didTappedButton()
}

final class CheckReservationInfoView: UIView {
  
  weak var delegate: CheckReservationInfoViewDelegate?
  private let disposeBag = DisposeBag()
  
  private let titleLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .bold18
    $0.text = "예약된정보확인하기"
  }
  
  private let descriptionLabel = UILabel().then {
    $0.textColor = .hex1A1E27
    $0.font = .regular14
    $0.text = "예정된예약정보를확인하고미리준비하세요"
  }
  
  private let checkReservationButton = HaramButton(type: .apply).then {
    $0.setTitleText(title: "예약확인")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [titleLabel, descriptionLabel, checkReservationButton].forEach { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(2)
      $0.leading.bottom.equalToSuperview()
    }
    
    checkReservationButton.snp.makeConstraints {
      $0.trailing.centerY.equalToSuperview()
      $0.height.equalTo(25)
      $0.width.equalTo(79)
    }
  }
  
  private func bind() {
    checkReservationButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedButton()
      }
      .disposed(by: disposeBag)
  }
}
