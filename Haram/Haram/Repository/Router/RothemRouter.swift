//
//  RothemRouter.swift
//  Haram
//
//  Created by 이건준 on 2023/08/18.
//

import Alamofire

enum RothemRouter {
  case inquireAllRoomInfo
  case inquireAllRothemNotice
  case inquireRothemHomeInfo(String)
  case inquireRothemRoomInfo(Int)
}

extension RothemRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo, .inquireRothemRoomInfo:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireAllRoomInfo:
      return "/rothem/admin/rooms"
    case .inquireAllRothemNotice:
      return "/rothem/v1/notices"
    case .inquireRothemHomeInfo(let userID):
      return "/rothem/v1/homes/\(userID)"
    case .inquireRothemRoomInfo(let roomSeq):
      return "/rothem/v1/rooms/\(roomSeq)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo, .inquireRothemRoomInfo:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireAllRoomInfo, .inquireAllRothemNotice, .inquireRothemHomeInfo, .inquireRothemRoomInfo:
      return .withAccessToken
    }
  }
}
