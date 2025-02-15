//
//  ChapelService.swift
//  Haram
//
//  Created by 이건준 on 2023/06/04.
//

import RxSwift

protocol IntranetRepository {
  func inquireChapelInfo() -> Single<InquireChapelInfoResponse>
  func inquireChapelDetail() -> Single<[InquireChapelDetailResponse]>
  func inquireScheduleInfo() -> Single<[InquireScheduleInfoResponse]>
  func inquireMileageInfo() -> Single<InquireMileageInfoResponse>
}

final class IntranetRepositoryImpl {
  
  private let service: BaseService
  
  init(service: BaseService = ApiService.shared) {
    self.service = service
  }
  
}

extension IntranetRepositoryImpl: IntranetRepository {
  
  func inquireChapelInfo() -> Single<InquireChapelInfoResponse> {
    service.request(router: IntranetRouter.inquireChapelInfo, type: InquireChapelInfoResponse.self)
  }
  
  func inquireChapelDetail() -> Single<[InquireChapelDetailResponse]> {
    service.request(router: IntranetRouter.inquireChapelDetail, type: [InquireChapelDetailResponse].self)
  }
  
  func inquireScheduleInfo() -> Single<[InquireScheduleInfoResponse]> {
    service.request(router: IntranetRouter.inquireScheduleInfo, type: [InquireScheduleInfoResponse].self)
  }
  
  func inquireMileageInfo() -> Single<InquireMileageInfoResponse> {
    service.request(router: IntranetRouter.inquireMileageInfo, type: InquireMileageInfoResponse.self)
  }
}

