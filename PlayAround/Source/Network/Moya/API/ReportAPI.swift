//
//  ReportAPI.swift
//  PlayAround
//
//  Created by haon on 2022/06/08.
//

import Foundation
import Moya

enum ReportAPI {
  case register(param: RegistReportRequest)
}
extension ReportAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .register : return "/v1/report/register"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .register:
      return .post
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .register(let param):
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

struct RegistReportRequest: Codable {
  let content: String?
  let foodId: Int?
  let usedId: Int?
  let communityNoticeId: Int?
  let communityBoardId: Int?
  
  init(
    content: String? = nil,
    foodId: Int? = nil,
    usedId: Int? = nil,
    communityNoticeId: Int? = nil,
    communityBoardId: Int? = nil
  ) {
    self.content = content
    self.foodId = foodId
    self.usedId = usedId
    self.communityNoticeId = communityNoticeId
    self.communityBoardId = communityBoardId
  }
}
