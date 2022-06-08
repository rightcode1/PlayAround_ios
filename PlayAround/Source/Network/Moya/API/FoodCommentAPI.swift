//
//  FoodCommentAPI.swift
//  PlayAround
//
//  Created by haon on 2022/06/02.
//

import Foundation
import Moya

enum FoodCommentAPI {
  
  case foodCommentList(foodId: Int)
  case foodCommentRegister(param: RegistFoodCommentRequest)
}
extension FoodCommentAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .foodCommentList : return "/v1/foodComment/list"
    case .foodCommentRegister : return "/v1/foodComment/register"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .foodCommentList:
      return .get
    case .foodCommentRegister:
      return .post
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .foodCommentList(let foodId):
      return .requestParameters(parameters: ["foodId": foodId], encoding: URLEncoding.queryString)
    case .foodCommentRegister(let param):
      return .requestJSONEncodable(param)
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

// MARK: - FoodCommentListResponse
struct FoodCommentListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [FoodCommentListData]
}

// MARK: - FoodCommentListData
struct FoodCommentListData: Codable {
  let id, userId, foodId: Int
  let content: String
  let depth: Int
  let createdAt: String
  let user: User
}

struct RegistFoodCommentRequest: Codable {
  let foodId: Int
  let content: String
  let foodCommentId: Int?
}
