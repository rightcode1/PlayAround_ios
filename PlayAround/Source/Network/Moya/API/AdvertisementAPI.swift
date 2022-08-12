//
//  AdvertisementAPI.swift
//  PlayAround
//
//  Created by haon on 2022/08/12.
//

import Foundation
import Moya

enum AdvertisementAPI {
  case list(param: AdvertisementListRequest)
}

extension AdvertisementAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var apiName: String {
    return "advertisement"
  }
  
  var path: String {
    switch self {
    case .list:
      return "/v1/\(apiName)/list"
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
      } else {
        return ["Content-type": "application/json"]
      }
    }
  }
  
}

enum AdvertisementLocation: String, Codable {
  case 메인배너
  case 광고배너
  case 광고리스트
}

enum AdvertisementCategory: String, Codable {
  case 반찬공유
  case 중고거래
}

struct AdvertisementListRequest: Codable {
  let location: AdvertisementLocation
  let category: AdvertisementCategory
}

// MARK: - AdvertisementListResponse
struct AdvertisementListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [AdvertisementData]
}

// MARK: - AdvertisementDetailResponse
struct AdvertisementDetailResponse: Codable {
  let statusCode: Int
  let message: String
  let data: AdvertisementData
}

// MARK: - AdvertisementData
struct AdvertisementData: Codable {
  let id: Int
  let title: String
  let sortCode: Int
  let diff, location: String
  let url: String?
  let thumbnail, image: String?
  let active: Bool
  let createdAt: String
  let viewCount: Int
}
