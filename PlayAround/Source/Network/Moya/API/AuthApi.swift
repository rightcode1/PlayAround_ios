//
//  AuthApi.swift
//  kospiKorea
//
//  Created by hoonKim on 2020/05/19.
//  Copyright © 2020 hoon Kim. All rights reserved.
//

import Foundation
import Alamofire
import Moya

// 서버랑 통신하는 api 만드는 곳
enum AuthApi {
  
  case versionCheck
  case login(param: LoginRequest)
  case join(param: JoinRequest)
  case isExistLoginId(email: String)
  case isExistNickname(nickname: String)
  case sendCode(param: SendCodeRequest)
  case confirm(tel: String, confirm: String)
  case findId(param: FindMyIdRequest)
  case changePassword(param: ChangePasswordRequest)
  case advertisement(location: String)

}
extension AuthApi: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  var path: String {
    switch self {
    case .versionCheck : return "/v1/version"
    case .login : return "/v1/auth/login"
    case .join: return "/v1/auth/join"
      
    case .isExistLoginId: return "/v1/auth/existLoginId"
    case .isExistNickname: return "/v1/auth/existNickname"
      
    case .sendCode : return "/v1/auth/CertificationNumberSMS"
    case .confirm : return "/v1/auth/confirm"
      
    case .findId : return "/v1/auth/findLoginId"
    case .changePassword : return "/v1/auth/passwordChange"
    case .advertisement: return "/v1/advertisement/list"
      
    }
    
  }
  
  var method: Moya.Method {
    switch self {
    case .versionCheck,
        .isExistLoginId,
        .isExistNickname,
        .sendCode,
        .findId,
        .confirm,
        .advertisement:
      return .get
    case .login,
        .join,
        .changePassword:
      return .post
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  var task: Task {
    switch self {
      
    case .versionCheck :
      return .requestPlain
      
    case .advertisement(let advertisement) :
      return .requestParameters(parameters: ["advertisement": advertisement], encoding: URLEncoding.queryString)
      
    case .login(let param) :
      return .requestJSONEncodable(param)

    case .join(let param):
      return .requestJSONEncodable(param)

    case .isExistLoginId(let email):
      return .requestParameters(parameters: ["loginId": email], encoding: URLEncoding.queryString)
      
    case .isExistNickname(let nickname):
      return .requestParameters(parameters: ["nickname": nickname], encoding: URLEncoding.queryString)
      
    case .sendCode(let param) :
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
    case .confirm(let tel, let confirm) :
      return .requestParameters(parameters: ["tel": tel , "confirm": confirm], encoding: URLEncoding.queryString)

    case .changePassword(let param) :
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
    case .findId(let param) :
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
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
