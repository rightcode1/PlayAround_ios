//
//  FoodLikeAPI.swift
//  PlayAround
//
//  Created by haon on 2022/06/03.
//

import Foundation
import Moya

enum FoodLikeAPI {
  case likeRegister(param: RegistFoodLikeRequest)
  case likeRemove(id: Int)
}
extension FoodLikeAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  var path: String {
    switch self {
    case .likeRegister : return "/v1/foodLike/register"
    case .likeRemove : return "/v1/foodLike/remove"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .likeRegister:
      return .post
    case .likeRemove:
      return .delete
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .likeRegister(let param):
      return .requestJSONEncodable(param)
    case .likeRemove(let id):
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
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

struct RegistFoodLikeRequest: Codable {
  let isLike: Bool
  let foodId: Int
}
