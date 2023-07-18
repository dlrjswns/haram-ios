//
//  LoginViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/04/02.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class LoginViewController: BaseViewController {
  
  private let viewModel: LoginViewModelType
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 118, left: 22, bottom: .zero, right: 22)
    $0.spacing = 15
  }
  
  private let loginImageView = UIImageView().then {
    $0.image = UIImage(named: "login")
    $0.contentMode = .scaleAspectFit
  }
  
  private let loginLabel = UILabel().then {
    $0.font = .regular
    $0.font = .systemFont(ofSize: 24)
    $0.textColor = .black
    $0.text = "로그인"
    $0.sizeToFit()
  }
  
  private let schoolLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .regular
    $0.font = .systemFont(ofSize: 14)
    $0.text = "한국성서대학교인트라넷"
    $0.sizeToFit()
  }
  
  private lazy var emailTextField = UITextField().then {
    $0.placeholder = "Email"
    $0.backgroundColor = .hexF5F5F5
    $0.tintColor = .black
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: 55))
    $0.leftViewMode = .always
    $0.returnKeyType = .next
    $0.autocapitalizationType = .none
    $0.delegate = self
  }
  
  private lazy var passwordTextField = UITextField().then {
    $0.placeholder = "Password"
    $0.backgroundColor = .hexF5F5F5
    $0.tintColor = .black
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD0D0D0.cgColor
    $0.leftView = UIView(frame: .init(x: .zero, y: .zero, width: 20, height: 55))
    $0.leftViewMode = .always
    $0.returnKeyType = .join
    $0.isSecureTextEntry = true
    $0.autocapitalizationType = .none
    $0.delegate = self
  }
  
  private lazy var loginButton = LoginButton().then {
    $0.delegate = self
  }
  
  private let loginAlertView = LoginAlertView()
  
  init(viewModel: LoginViewModelType = LoginViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  deinit {
//    print("디이닛")
//    removeKeyboardNotification()
//  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerKeyboardNotification()
    UserManager.shared.clearUserInformations()
    guard UserManager.shared.hasAccessToken && UserManager.shared.hasRefreshToken,
          let userID = emailTextField.text else {
      return
    }
    
    let vc = HaramTabbarController(userID: userID)
    vc.modalPresentationStyle = .overFullScreen
    present(vc, animated: true) { [weak self] in
      self?.removeKeyboardNotification()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
    
    viewModel.loginToken
      .skip(1)
      .drive(with: self) { owner, result in
        guard UserManager.shared.hasAccessToken && UserManager.shared.hasRefreshToken,
              let userID = owner.emailTextField.text else { return }
        
        let vc = HaramTabbarController(userID: userID)
        vc.modalPresentationStyle = .overFullScreen
        owner.present(vc, animated: true) { [weak self] in
          self?.removeKeyboardNotification()
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(containerView)
    [loginImageView, loginLabel, schoolLabel, emailTextField, passwordTextField, loginButton, loginAlertView].forEach { containerView.addArrangedSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    containerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    [emailTextField, passwordTextField].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(55)
      }
    }
    
    loginLabel.snp.makeConstraints {
      $0.height.equalTo(30)
    }
    
    schoolLabel.snp.makeConstraints {
      $0.height.equalTo(18)
    }
    
    loginButton.snp.makeConstraints {
      $0.height.equalTo(48)
    }
    
    loginAlertView.snp.makeConstraints {
      $0.width.equalTo(216)
      $0.height.equalTo(16)
    }
    containerView.setCustomSpacing(37, after: loginImageView)
    containerView.setCustomSpacing(30, after: schoolLabel)
    containerView.setCustomSpacing(83, after: loginButton)
  }
}

extension LoginViewController: LoginButtonDelegate {
  func didTappedLoginButton() {
    guard let userID = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
          let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
    viewModel.userID.onNext(userID)
    viewModel.password.onNext(password)
  }
  
  func didTappedFindPasswordButton() {
    viewModel.userID.onNext("")
  }
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    } else {
      passwordTextField.resignFirstResponder()
    }
    return true
  }
}

extension LoginViewController {
  func registerKeyboardNotification() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self, selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  func removeKeyboardNotification() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  func keyboardWillShow(_ sender: Notification) {
    guard let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }
    
    let keyboardHeight = keyboardSize.height
    
    if self.view.window?.frame.origin.y == 0 {
      self.view.window?.frame.origin.y -= keyboardHeight
    }

    
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc
  func keyboardWillHide(_ sender: Notification) {

    self.view.window?.frame.origin.y = 0
    UIView.animate(withDuration: 1) {
      self.view.layoutIfNeeded()
    }
  }
}
