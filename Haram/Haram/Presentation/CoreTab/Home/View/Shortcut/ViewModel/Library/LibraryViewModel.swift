//
//  LibraryViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/05/29.
//

import Foundation

import RxSwift
import RxCocoa

protocol LibraryViewModelType {
  
  func inquireLibrary()
  
  var newBookModel: Driver<[NewLibraryCollectionViewCellModel]> { get }
  var bestBookModel: Driver<[PopularLibraryCollectionViewCellModel]> { get }
  var rentalBookModel: Driver<[RentalLibraryCollectionViewCellModel]> { get }
  var bannerImage: Driver<URL?> { get }
  var isLoading: Driver<Bool> { get }
  var errorMessage: Signal<HaramError> { get }
}

final class LibraryViewModel {
  
  private let disposeBag = DisposeBag()
  private let libraryRepository: LibraryRepository
  
  private let currentNewBookModel    = BehaviorRelay<[NewLibraryCollectionViewCellModel]>(value: [])
  private let currentBestBookModel   = BehaviorRelay<[PopularLibraryCollectionViewCellModel]>(value: [])
  private let currentRentalBookModel = BehaviorRelay<[RentalLibraryCollectionViewCellModel]>(value: [])
  private let bannerImageRelay       = PublishRelay<URL?>()
  private let isLoadingSubject       = BehaviorSubject<Bool>(value: true)
  private let errorMessageRelay      = BehaviorRelay<HaramError?>(value: nil)
  
  init(libraryRepostory: LibraryRepository = LibraryRepositoryImpl()) {
    self.libraryRepository = libraryRepostory
  }
}

extension LibraryViewModel: LibraryViewModelType {
  var errorMessage: RxCocoa.Signal<HaramError> {
    errorMessageRelay
      .compactMap { $0 }
      .asSignal(onErrorSignalWith: .empty())
  }
  
  func inquireLibrary() {
    let inquireLibrary = libraryRepository.inquireLibrary()
    
    inquireLibrary
      .subscribe(with: self, onSuccess: { owner, response in
        owner.currentNewBookModel.accept(response.newBook.map { NewLibraryCollectionViewCellModel(bookInfo: $0) })
        owner.currentBestBookModel.accept(response.bestBook.map { PopularLibraryCollectionViewCellModel(bookInfo: $0) })
        owner.currentRentalBookModel.accept(response.rentalBook.map {
          RentalLibraryCollectionViewCellModel(bookInfo: $0) })
        owner.bannerImageRelay.accept(URL(string: response.image.first!))
        
        owner.isLoadingSubject.onNext(false)
      }, onFailure: { owner, error in
        guard let error = error as? HaramError else { return }
        owner.errorMessageRelay.accept(error)
      })
      .disposed(by: disposeBag)
  }
  
  var newBookModel: Driver<[NewLibraryCollectionViewCellModel]> {
    currentNewBookModel
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var bestBookModel: Driver<[PopularLibraryCollectionViewCellModel]> {
    currentBestBookModel
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var rentalBookModel: Driver<[RentalLibraryCollectionViewCellModel]> {
    currentRentalBookModel
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var bannerImage: Driver<URL?> {
    bannerImageRelay
      .asDriver(onErrorDriveWith: .empty())
  }
  
  var isLoading: Driver<Bool> {
    isLoadingSubject
      .asDriver(onErrorJustReturn: true)
  }
}
