//
//  LibraryRentalListView.swift
//  Haram
//
//  Created by 이건준 on 2023/06/14.
//

import UIKit

import SnapKit
import Then

final class LibraryRentalListView: UIView {
  
  private let lineView1 = UIView().then {
    $0.backgroundColor = .hexD8D8DA
  }
  
  private let rentalInfoLabel = UILabel().then {
    $0.text = "대여정보"
    $0.font = .bold18
    $0.textColor = .black
  }
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.backgroundColor = .hexF2F3F5
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  private let lineView = UIView().then {
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
    addSubview(lineView1)
    addSubview(rentalInfoLabel)
    addSubview(containerView)
    addSubview(lineView)
    
    lineView1.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(1)
    }
    
    rentalInfoLabel.snp.makeConstraints {
      $0.top.equalTo(lineView1.snp.bottom).offset(21)
      $0.leading.equalToSuperview()
    }
    
    containerView.snp.makeConstraints {
      $0.top.equalTo(rentalInfoLabel.snp.bottom).offset(10)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    lineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.directionalHorizontalEdges.equalToSuperview()
      $0.top.equalTo(containerView.snp.bottom).offset(20)
      $0.bottom.equalToSuperview()
    }
  }
  
  func configureUI(with model: [LibraryRentalViewModel]) {
    
    containerView.subviews.forEach { $0.removeFromSuperview() }
    
    if model.isEmpty {
      let emptyView = RentalEmptyView()
      emptyView.snp.makeConstraints {
        $0.height.equalTo(80)
      }
      containerView.addArrangedSubview(emptyView)
      return
    }
    
    model.forEach { rentalModel in
      let vw = LibraryRentalView()
      vw.configureUI(with: rentalModel)
      vw.snp.makeConstraints {
        $0.height.equalTo(307 / 4)
      }
      containerView.addArrangedSubview(vw)
    }
  }
}

// MARK: - LibraryRentalView Model

struct LibraryRentalViewModel {
  let register: String
  let number: String
  let holdingInstitution: String
  let loanStatus: String
  
  init(response: RequestBookLoanStatusResponse) {
    register = response.register
    number = response.number
    holdingInstitution = response.holdingInstitution
    loanStatus = response.loanStatus
  }
}

final class LibraryRentalView: UIView {
  
  private let registerLabel = UILabel().then {
    $0.font = .bold14
    $0.textColor = .black
  }
  
  private let numberLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
  }
  
  private let holdingInstitutionLabel = UILabel().then {
    $0.font = .regular14
    $0.textColor = .black
  }
  
  private let loanStatusLabel = UILabel().then {
    $0.font = .bold18
    $0.textColor = .black
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [registerLabel, numberLabel, holdingInstitutionLabel, loanStatusLabel].forEach { addSubview($0) }
    
    numberLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(15)
      $0.centerY.equalToSuperview()
    }
    
    registerLabel.snp.makeConstraints {
      $0.bottom.equalTo(numberLabel.snp.top).offset(-1)
      $0.leading.equalToSuperview().inset(15)
      $0.trailing.lessThanOrEqualTo(loanStatusLabel.snp.leading)
    }
    
    holdingInstitutionLabel.snp.makeConstraints {
      $0.top.equalTo(numberLabel.snp.bottom).offset(1)
      $0.leading.equalTo(numberLabel)
      $0.trailing.lessThanOrEqualTo(loanStatusLabel.snp.leading)
    }
    
    loanStatusLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(14)
      $0.centerY.equalToSuperview()
    }
  }
  
  func configureUI(with model: LibraryRentalViewModel) {
    registerLabel.text = model.register
    numberLabel.text = "청구기호 : \(model.number)"
    holdingInstitutionLabel.text = "소장처 : \(model.holdingInstitution)"
    loanStatusLabel.text = model.loanStatus
  }
}

extension LibraryRentalListView {
  final class RentalEmptyView: UIView {
    
    private let alertLabel = UILabel().then {
      $0.textColor = .hex1A1E27
      $0.font = .bold18
      $0.text = "대여 가능한 정보가 없습니다."
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      configureUI()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
      backgroundColor = .hexF2F3F5
      layer.masksToBounds = true
      layer.cornerRadius = 10
      
      addSubview(alertLabel)
      alertLabel.snp.makeConstraints {
        $0.center.equalToSuperview()
      }
    }
  }
}
