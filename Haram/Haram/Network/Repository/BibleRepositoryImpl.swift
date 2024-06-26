//
//  BibleService.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import RxSwift

protocol BibleRepository {
  func inquireChapterToBible(request: InquireChapterToBibleRequest) -> Single<[InquireChapterToBibleResponse]>
  func inquireBibleHomeInfo() -> Single<InquireBibleHomeInfoResponse>
  func inquireBibleDetailInfo(noticeSeq: Int) -> Single<InquireBibleDetailInfoResponse>
}

final class BibleRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension BibleRepositoryImpl: BibleRepository {
  func inquireBibleDetailInfo(noticeSeq: Int) -> RxSwift.Single<InquireBibleDetailInfoResponse> {
    service.betarequest(router: BibleRouter.inquireBibleDetailInfo(noticeSeq), type: InquireBibleDetailInfoResponse.self)
  }
  
  
  func inquireChapterToBible(request: InquireChapterToBibleRequest) -> Single<[InquireChapterToBibleResponse]> {
    service.betarequest(router: BibleRouter.inquireChapterToBible(request), type: [InquireChapterToBibleResponse].self)
  }
  
  func inquireBibleHomeInfo() -> Single<InquireBibleHomeInfoResponse> {
    service.betarequest(router: BibleRouter.inquireBibleHomeInfo, type: InquireBibleHomeInfoResponse.self)
  }
}

