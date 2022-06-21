//
//  InquiryAPI.swift
//  PlayAround
//
//  Created by haon on 2022/06/20.
//

import Foundation
import Moya

enum InquiryAPI {
  case list
  case register(param: RegistInquiryRequest)
}

extension InquiryAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .list:
      return "/v1/inquiry/list"
    case .register:
      return "/v1/inquiry/register"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .list:
      return .get
      
    case .register:
      return .post
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .list:
      return .requestPlain
    case .register(let param):
      return .requestJSONEncodable(param)
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

struct RegistInquiryRequest: Codable {
  let title: String
  let content: String
}

struct InquiryListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [InquiryListData]
}

struct InquiryListData: Codable {
  let id: Int
  let title: String
  let content: String
  let createdAt: String
  let comment: String?
  var isOpened: Bool? 
}
