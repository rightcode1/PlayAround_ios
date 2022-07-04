//
//  HashtagAPI.swift
//  PlayAround
//
//  Created by haon on 2022/06/14.
//

import Foundation
import Moya

enum HashtagAPI {
  case list(param: HashtagListRequest)
}

extension HashtagAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .list : return "/v1/hashtag/list"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .list:
      return .get
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .list(let param):
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
    }
  }
  
  var headers: [String : String]? {
    switch self {
    default:
      if let token = DataHelperTool.token {
        return ["Content-type": "application/json", "Authorization": token]
      }else {
        return ["Content-type": "application/json"]
      }
    }
  }
}

enum HashtagDiff: String, Codable {
  case food
  case used
}

struct HashtagListRequest: Codable {
  let search: String
  let diff: HashtagDiff?
}

// MARK: - HashtagListResponse
struct HashtagListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [HashtagListData]
}

// MARK: - HashtagListData
struct HashtagListData: Codable {
  let id: Int
  let name: String
  let count: Int
}
