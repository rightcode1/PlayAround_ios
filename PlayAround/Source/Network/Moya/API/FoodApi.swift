//
//  FoodApi.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/18.
//

import Foundation
import Alamofire
import Moya
import UIKit

// 서버랑 통신하는 api 만드는 곳
enum FoodApi {
  
  case foodList(param: FoodListRequest)
  //  case login(param: LoginRequest)
  //  case join(param: JoinRequest)
  //  case isExistLoginId(email: String)
  //  case isExistNickname(nickname: String)
  //  case sendCode(param: SendCodeRequest)
  //  case confirm(tel: String, confirm: String)
  //  case findId(param: FindMyIdRequest)
  //  case changePassword(param: ChangePasswordRequest)
}
extension FoodApi: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  var path: String {
    switch self {
    case .foodList : return "/v1/food/list"
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
    case .foodList:
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
    case .foodList(let param) :
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


struct FoodListRequest: Codable {
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
    isReport: String? = nil
  ) {
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

enum FoodCategory: String, Codable {
  case 전체
  case 국물
  case 찜
  case 볶음
  case 나물
  case 베이커리
  case 저장
  
  func onImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "sideCategoryFullColorOn1") ?? UIImage()
    case .국물:
      return UIImage(named: "sideDishCategoryFullColorOn2") ?? UIImage()
    case .찜:
      return UIImage(named: "sideDishCategoryFullColorOn3") ?? UIImage()
    case .볶음:
      return UIImage(named: "sideDishCategoryFullColorOn4") ?? UIImage()
    case .나물:
      return UIImage(named: "sideDishCategoryFullColorOn5") ?? UIImage()
    case .베이커리:
      return UIImage(named: "sideDishCategoryFullColorOn6") ?? UIImage()
    case .저장:
      return UIImage(named: "sideDishCategoryFullColorOn7") ?? UIImage()
    }
  }
  
  func offImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "sideCategoryFullColorOff1") ?? UIImage()
    case .국물:
      return UIImage(named: "sideDishCategoryFullColorOff2") ?? UIImage()
    case .찜:
      return UIImage(named: "sideDishCategoryFullColorOff3") ?? UIImage()
    case .볶음:
      return UIImage(named: "sideDishCategoryFullColorOff4") ?? UIImage()
    case .나물:
      return UIImage(named: "sideDishCategoryFullColorOff5") ?? UIImage()
    case .베이커리:
      return UIImage(named: "sideDishCategoryFullColorOff6") ?? UIImage()
    case .저장:
      return UIImage(named: "sideDishCategoryFullColorOff7") ?? UIImage()
    }
  }
}


// MARK: - FoodListResponse
struct FoodListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [FoodListData]
}

// MARK: - FoodListData
struct FoodListData: Codable {
  let id: Int
  let thumbnail: String?
  let category, name: String
  let price, wishCount: Int
  let isWish: Bool
  let isLike: Bool?
  let likeCount, dislikeCount: Int
  let statusSale: Bool
  let address: String
  let viewCount, villageId: Int
  let user: User
  let commentCount: Int
  let status: FoodStatus
  let userCount: Int?
  let dueDate: String?
  let requestCount: Int
  let isRequest: Bool
  let hashtag: [String]
  let isReport: Bool
}

enum FoodStatus: String, Codable {
  case 조리예정 = "조리예정"
  case 조리완료 = "조리완료"
}

enum Thumbnail: Codable {
  case bool(Bool)
  case string(String)
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let x = try? container.decode(Bool.self) {
      self = .bool(x)
      return
    }
    if let x = try? container.decode(String.self) {
      self = .string(x)
      return
    }
    throw DecodingError.typeMismatch(Thumbnail.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Thumbnail"))
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .bool(let x):
      try container.encode(x)
    case .string(let x):
      try container.encode(x)
    }
  }
}
