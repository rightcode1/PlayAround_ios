//
//  FollowAPI.swift
//  PlayAround
//
//  Created by haon on 2022/06/07.
//

import Foundation
import Moya

enum FollowAPI {
  case register(param: RegistFollowRequest)
  case remove(userId: Int)
}
extension FollowAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .register : return "/v1/follow/register"
    case .remove : return "/v1/follow/remove"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .register:
      return .post
    case .remove:
      return .delete
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .register(let param):
      return .requestJSONEncodable(param)
    case .remove(let userId):
      return .requestParameters(parameters: ["userId": userId], encoding: URLEncoding.queryString)
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

struct RegistFollowRequest: Codable {
  let userId: Int
}
