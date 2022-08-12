//
//  VillageApi.swift
//  PlayAround
//
//  Created by 이남기 on 2022/06/22.
//

import Foundation
import Moya

enum VillageApi {
  case villageList(param: VillageListRequest)
  case MyVillageRegist(param: MyVillage)
  
  
//  case mㅛ퍄ㅣㅣ(latitude:String, longitude:String)
}

extension VillageApi: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .villageList:
      return "/v1/village/list"
    case .MyVillageRegist:
      return "/v1/villageUser/register"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .villageList:
      return .get
    case .MyVillageRegist:
      return .post
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .villageList(let param):
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
    case .MyVillageRegist(let param):
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

struct MyVillage: Codable {
  let villageId: Int
}

struct VillageListRequest: Codable {
  let latitude:String
  let longitude:String
  let isMyVillage:String
}
