//
//  FAQAPI.swift
//  academyNow
//
//  Created by haon on 2022/06/11.
//

import Foundation
import Moya

enum FAQAPI {
  case list(diff: FAQDiff)
}

extension FAQAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .list:
      return "/v1/faq/list"
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
    case .list(let diff):
      return .requestParameters(parameters: ["diff": diff], encoding: URLEncoding.queryString)
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

enum FAQDiff: String, Codable {
  case 동네생활
  case 이용방법
  case 약관
  case 거래
  case 기타
  case 약관2
}

// MARK: - FAQListResponse
struct FAQListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [FAQListData]
}

// MARK: - FAQListData
struct FAQListData: Codable {
  let id: Int
  let diff, title, content, createdAt: String
  let sortCode: Int
  var isOpened: Bool?
}
