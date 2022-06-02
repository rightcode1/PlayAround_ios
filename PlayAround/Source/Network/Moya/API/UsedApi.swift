//
//  UsedApi.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/18.
//

import Foundation
import Moya

// 서버랑 통신하는 api 만드는 곳
enum UsedApi {
  
  case UsedList(param: UsedListRequest)
  //  case login(param: LoginRequest)
  //  case join(param: JoinRequest)
  //  case isExistLoginId(email: String)
  //  case isExistNickname(nickname: String)
  //  case sendCode(param: SendCodeRequest)
  //  case confirm(tel: String, confirm: String)
  //  case findId(param: FindMyIdRequest)
  //  case changePassword(param: ChangePasswordRequest)
}
extension UsedApi: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  var path: String {
    switch self {
    case .UsedList : return "/v1/used/list"
      //    case .login : return "/v1/auth/login"
      //    case .join: return "/v1/auth/join"
      //
      //    case .isExistLoginId: return "/v1/auth/existLoginId"
      //    case .isExistNickname: return "/v1/auth/existNickname"
      //
      //    case .sendCode : return "/v1/auth/CertificationNumberSMS"
      //    case .confirm : return "/v1/auth/confirm"
      //
      //    case .findId : return "/v1/auth/findLoginId"
      //    case .changePassword : return "/v1/auth/passwordChange"
    }
    
  }
  
  var method: Moya.Method {
    switch self {
    case .UsedList:
      return .get
      //    case .login,
      //        .join,
      //        .changePassword:
      //      return .post
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  var task: Task {
    switch self {
    case .UsedList(let param) :
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
      //    case .login(let param) :
      //      return .requestJSONEncodable(param)
      //
      //    case .join(let param):
      //      return .requestJSONEncodable(param)
      //
      //    case .isExistLoginId(let email):
      //      return .requestParameters(parameters: ["loginId": email], encoding: URLEncoding.queryString)
      //
      //    case .isExistNickname(let nickname):
      //      return .requestParameters(parameters: ["nickname": nickname], encoding: URLEncoding.queryString)
      //
      //    case .sendCode(let param) :
      //      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      //
      //    case .confirm(let tel, let confirm) :
      //      return .requestParameters(parameters: ["tel": tel , "confirm": confirm], encoding: URLEncoding.queryString)
      //
      //    case .changePassword(let param) :
      //      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      //
      //    case .findId(let param) :
      //      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
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


struct UsedListRequest: Codable {
  let category: FoodCategory?
  let search: String?
  let statusSale: String?
  let si: String?
  let gu: String?
  let dong: String?
  let villageId: Int?
  let hashtag: String?
  let isWish: String?
  let userId: String?
  let isReport: String?
  
  
  init(
  category: FoodCategory? = nil,
  search: String? = nil,
  statusSale: String? = nil,
  si: String? = nil,
  gu: String? = nil,
  dong: String? = nil,
  villageId: Int? = nil,
  hashtag: String? = nil,
  isWish: String? = nil,
  userId: String? = nil,
  isReport: String? = nil) {
    self.category = category
    self.search = search
    self.statusSale = statusSale
    self.si = statusSale
    self.gu = gu
    self.dong = dong
    self.villageId = villageId
    self.hashtag = hashtag
    self.isWish = isWish
    self.userId = userId
    self.isReport = isReport
  }
  
}

enum statusSale: String, Codable {
  case 판매중
  case 판매완료
}
