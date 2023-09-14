//
//  FoodApi.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/18.
//

import Foundation
import Moya

enum SettingApi {
  
  case register(param: FoodRegistRequest)
  case update(id: Int, param: FoodRegistRequest)
  
}
extension SettingApi: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  
  var path: String {
    switch self {
    case .register : return "/v1/notification/register"
    case .update : return "/v1/notification/update"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .register:
      return .post
    case .update:
      return .put
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .register(let param):
      return .requestJSONEncodable(param)
    case .update(let id, let param):
      return .requestCompositeParameters(bodyParameters: param.dictionary ?? [:], bodyEncoding: JSONEncoding.default, urlParameters: ["id": id])
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

