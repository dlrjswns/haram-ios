//
//  IntranetLoginViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/25.
//

import RxSwift
import RxCocoa

protocol IntranetLoginViewModelType {
  func whichIntranetInfo(intranetID: String, intranetPassword: String)
  
  var successIntranetLogin: Signal<Void> { get }
  var isLoading: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class IntranetLoginViewModel {
  
  private let disposeBag           = DisposeBag()
  private let authRepository: AuthRepository
  
  
//  private let intranetInfoSubject  = PublishSubject<(String, String)>()
  private let intranetLoginMessage = PublishSubject<Void>()
  private let isLoadingSubject     = BehaviorSubject<Bool>(value: false)
  private let errorMessageRelay    = PublishRelay<HaramError>()
  
  init(authRepository: AuthRepository = AuthRepositoryImpl()) {
    self.authRepository = authRepository
//    tryRequestIntranetToken()
  }
  
  private func tryRequestIntranetToken() {
    
//    intranetInfoSubject
//      .do(onNext: { [weak self] _ in
//        guard let self = self else { return }
//        self.isLoadingSubject.onNext(true)
//      })
//      .withUnretained(self)
//      .flatMapLatest { owner, intranetInfo in
//        let (intranetID, intranetPWD) = intranetInfo
//        return owner.authRepository.loginIntranet(
//          request: .init(
//            intranetID: intranetID,
//            intranetPWD: intranetPWD
//          )
//        )
//      }
//      .subscribe(with: self, onNext: { owner, result in
//        switch result {
//        case .success(_):
//          owner.intranetLoginMessage.onNext(())
//          owner.isLoadingSubject.onNext(false)
//        case .failure(let error):
//          owner.isLoadingSubject.onNext(false)
//          owner.errorMessageRelay.accept(error)
//        }
//      })
//      .disposed(by: disposeBag)
  }
  
}

extension IntranetLoginViewModel: IntranetLoginViewModelType {
  func whichIntranetInfo(intranetID: String, intranetPassword: String) {
    
    if intranetID.isEmpty {
      errorMessageRelay.accept(.noUserID)
      return
    } else if intranetPassword.isEmpty {
      errorMessageRelay.accept(.noPWD)
      return
    }
    
    self.isLoadingSubject.onNext(true)
    
    authRepository.loginIntranet(
      request: .init(
        intranetID: intranetID,
        intranetPWD: intranetPassword
      )
    )
    .subscribe(with: self, onNext: { owner, result in
      switch result {
      case .success(_):
        owner.intranetLoginMessage.onNext(())
      case .failure(let error):
        owner.errorMessageRelay.accept(error)
      }
      owner.isLoadingSubject.onNext(false)
    })
    .disposed(by: disposeBag)
  }
  
  var isLoading: RxCocoa.Driver<Bool> {
    isLoadingSubject.asDriver(onErrorJustReturn: false)
  }
  
//  var whichIntranetInfo: AnyObserver<(String, String)> {
//    intranetInfoSubject.asObserver()
//  }
  
  var successIntranetLogin: Signal<Void> {
    intranetLoginMessage.asSignal(onErrorSignalWith: .empty())
  }
  
  var errorMessage: Signal<HaramError> {
    errorMessageRelay.asSignal(onErrorSignalWith: .empty())
  }
}
