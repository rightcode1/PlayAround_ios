//
//  NoticeAPI.swift
//  academyNow
//
//  Created by haon on 2022/06/11.
//

import Foundation
import Moya

enum NoticeAPI {
  case list
}

extension NoticeAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .list:
      return "/v1/notice/list"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case
        .list:
      return .get
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .list:
      return .requestPlain
    }
  }
  
  var headers: [String : String]? {
    switch self {
    default:
      if let token = DataHelperTool.token {
        return ["Content-type": "application/json", "Authorization": token]
      } else {
        return ["Content-type": "application/json"]
      }
    }
  }
  
}


// MARK: - NoticeListResponse
struct NoticeListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [NoticeListData]
}

// MARK: - NoticeListData
struct NoticeListData: Codable {
  let id: Int
  let title, content, createdAt: String
  let viewCount: Int
}
