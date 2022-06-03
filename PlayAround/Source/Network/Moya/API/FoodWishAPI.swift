//
//  FoodWishAPI.swift
//  PlayAround
//
//  Created by haon on 2022/06/03.
//

import Foundation
import Moya

enum FoodWishAPI {
  case wishRegister(param: RegistFoodWishRequest)
  case wishRemove(foodId: Int)
}
extension FoodWishAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  var path: String {
    switch self {
    case .wishRegister : return "/v1/foodWish/register"
    case .wishRemove : return "/v1/foodWish/remove"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .wishRegister:
      return .post
    case .wishRemove:
      return .delete
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .wishRegister(let param):
      return .requestJSONEncodable(param)
    case .wishRemove(let foodId):
      return .requestParameters(parameters: ["foodId": foodId], encoding: URLEncoding.queryString)
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

struct RegistFoodWishRequest: Codable {
  let foodId: Int
}
