//
//  ChapelViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/07/21.
//

import RxSwift
import RxCocoa

protocol ChapelViewModelType {
  
  func inquireChapelInfo()
  func inquireChapelDetail()
  
  var chapelListModel: Driver<[ChapelCollectionViewCellModel]> { get }
  var chapelHeaderModel: Driver<ChapelCollectionHeaderViewModel?> { get }
  var isLoading: Driver<Bool> { get }
  
  var errorMessage: Signal<HaramError> { get }
}

final class ChapelViewModel {
  
  private let disposeBag = DisposeBag()
  private let intranetRepository: IntranetRepository
  
  private let chapelListModelRelay   = PublishRelay<[ChapelCollectionViewCellModel]>()
  private let chapelHeaderModelRelay = PublishRelay<ChapelCollectionHeaderViewModel?>()
  private let isLoadingSubject       = BehaviorSubject<Bool>(value: true)
  private let errorMessageRelay    = BehaviorRelay<HaramError?>(value: nil)
  
  init(intranetRepository: IntranetRepository = IntranetRepositoryImpl()) {
    self.intranetRepository = intranetRepository
  }
}

extension ChapelViewModel: ChapelViewModelType {
  
  func inquireChapelInfo() {
    intranetRepository.inquireChapelInfo()
      .subscribe(with: self) { owner, result in
        switch result {
        case let .success(response):
          let confirmationDays = Int(response.confirmationDays)!
          let regulatedDays = Int(response.regulateDays)!
          
          owner.chapelHeaderModelRelay.accept(
            ChapelCollectionHeaderViewModel(
              chapelDayViewModel: response.confirmationDays,
              chapelInfoViewModel: .init(
                attendanceDays: response.attendanceDays,
                remainDays: "\(regulatedDays - confirmationDays)",
                lateDays: response.lateDays
              )
            )
          )
        case let .failure(error):
          owner.errorMessageRelay.accept(error)
        }
        
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
  }
  
  func inquireChapelDetail() {
    intranetRepository.inquireChapelDetail()
      .subscribe(with: self) { owner, result in
        switch result {
        case let .success(response):
          let chapelListModel = response.map { ChapelCollectionViewCellModel(response: $0) }
          owner.chapelListModelRelay.accept(chapelListModel)
        case let .failure(error):
          owner.errorMessageRelay.accept(error)
        }
        
        owner.isLoadingSubject.onNext(false)
      }
      .disposed(by: disposeBag)
  }
  
  var chapelListModel: Driver<[ChapelCollectionViewCellModel]> {
    chapelListModelRelay.asDriver(onErrorJustReturn: [])
  }
  var chapelHeaderModel: Driver<ChapelCollectionHeaderViewModel?> {
    chapelHeaderModelRelay.asDriver(onErrorJustReturn: nil)
  }
  var isLoading: Driver<Bool> {
    isLoadingSubject.distinctUntilChanged().asDriver(onErrorJustReturn: false)
  }
  var errorMessage: Signal<HaramError> {
    errorMessageRelay
      .compactMap { $0 }
      .asSignal(onErrorSignalWith: .empty())
  }
}
