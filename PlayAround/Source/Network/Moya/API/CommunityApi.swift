//
//  CommunityApi.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/16.
//

import Foundation
import Alamofire
import Moya
import UIKit

// 서버랑 통신하는 api 만드는 곳
enum CommunityApi {
  
  case CommuntyList(param: categoryListRequest)
  case CommuntyDetail(id: Int)
}
extension CommunityApi: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  var path: String {
    switch self {
    case .CommuntyList : return "/v1/community/list"
    case .CommuntyDetail : return "/v1/community/detail"
    }
    
  }
  
  var method: Moya.Method {
    switch self {
    case .CommuntyDetail,
        .CommuntyList:
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
      
    case .CommuntyDetail(let id) :
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
      
    case .CommuntyList(let param) :
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


struct categoryListRequest: Codable {
  let category: CommunityCategory?
  let myList: Bool?
  let villageId: Int?
  let si: String?
  let gu: String?
  let dong: String?
  let search: String?
  let latitude: String?
  let longitude: String?
  let userId: Int?
  let sort: String?
  
  init(
    category: CommunityCategory? = nil,
    myList: Bool? = nil,
    villageId: Int? = nil,
    si: String? = nil,
    gu: String? = nil,
    dong: String? = nil,
    search: String? = nil,
    latitude: String? = nil,
    longitude: String? = nil,
    userId: Int? = nil,
    sort: String? = nil
  ) {
    self.category = category
    self.myList = myList
    self.villageId = villageId
    self.si = si
    self.gu = gu
    self.dong = dong
    self.search = search
    self.latitude = latitude
    self.longitude = longitude
    self.userId = userId
    self.sort = sort
  }
  
}
enum CommunityCategory: String, Codable {
  case 전체
  case 아파트별모임
  case 스터디그룹
  case 동호회
  case 맘카페
  case 기타
  func onImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "sideCategoryFullColorOn1") ?? UIImage()
    case .아파트별모임:
      return UIImage(named: "sideCommunityCategoryFullColorOn2") ?? UIImage()
    case .스터디그룹:
      return UIImage(named: "sideCommunityCategoryFullColorOn3") ?? UIImage()
    case .동호회:
      return UIImage(named: "sideCommunityCategoryFullColorOn4") ?? UIImage()
    case .맘카페:
      return UIImage(named: "sideCommunityCategoryFullColorOn5") ?? UIImage()
    case .기타:
      return UIImage(named: "sideCommunityCategoryFullColorOn6") ?? UIImage()
    }
  }
  
  func offImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "sideCategoryFullColorOff1") ?? UIImage()
    case .아파트별모임:
      return UIImage(named: "sideCommunityCategoryFullColorOff2") ?? UIImage()
    case .스터디그룹:
      return UIImage(named: "sideCommunityCategoryFullColorOff3") ?? UIImage()
    case .동호회:
      return UIImage(named: "sideCommunityCategoryFullColorOff4") ?? UIImage()
    case .맘카페:
      return UIImage(named: "sideCommunityCategoryFullColorOff5") ?? UIImage()
    case .기타:
      return UIImage(named: "sideCommunityCategoryFullColorOff6") ?? UIImage()
    }
  }
}

