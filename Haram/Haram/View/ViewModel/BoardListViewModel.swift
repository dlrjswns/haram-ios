//
//  BoardListViewModel.swift
//  Haram
//
//  Created by 이건준 on 2023/08/16.
//

import RxSwift
import RxCocoa

protocol BoardListViewModelType {
  var whichBoardType: AnyObserver<BoardType> { get }
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> { get }
}

final class BoardListViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let currentBoardTypeRelay = PublishSubject<BoardType>()
  private let currentBoardListRelay = BehaviorRelay<[BoardListCollectionViewCellModel]>(value: [])
  
  init() {
    inquireBoardList()
  }
}

extension BoardListViewModel {
  private func inquireBoardList() {
    let inquireBoardList = currentBoardTypeRelay
      .flatMapLatest(BoardService.shared.inquireBoardlist(boardType: ))
    
    let inquireBoardListToResponse = inquireBoardList
      .compactMap { result -> [InquireBoardlistResponse]? in
        guard case .success(let response) = result else { return nil }
        return response
      }
    
    inquireBoardListToResponse
      .map { $0.map { BoardListCollectionViewCellModel(response: $0) } }
      .subscribe(with: self) { owner, model in
        owner.currentBoardListRelay.accept(model)
      }
      .disposed(by: disposeBag)
  }
}

extension BoardListViewModel: BoardListViewModelType {
  var boardListModel: Driver<[BoardListCollectionViewCellModel]> {
    currentBoardListRelay.asDriver()
  }
  
  var whichBoardType: AnyObserver<BoardType> {
    currentBoardTypeRelay.asObserver()
  }
}
