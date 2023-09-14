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
  
  case CommuntyJoin(param: JoinCommunity)
  case CommunityJoinerList(param: JoinCommunity)
  case CommunityJoinerUpdate(id:Int ,param: CommunityJoinerUpdateRequest)
  case CommuntyRegister(param: RegistCommunityRegister)
    case CommuntyUpdate(id:Int,param: RegistCommunityRegister)
  
  
  case CommuntyList(param: categoryListRequest)
    case CommuntyDetail(param: communityDetailRequest)
  //  case CommuntyRegister(param: )
  
  case CommuntyNotice(param: ComunityNoticeRequest)
  case CommuntyBoard(param: ComunityNoticeRequest)
  
  case CommuntyLike(param: ComunityLikeRequest)
    case CommuntyDisLike(id: Int)
    
    
    case CommuntyInfoLike(param: ComunityInfoLikeRequest)
      case CommuntyInfoDisLike(id: Int)
    
    case CommunityBoardDown(param: ComunityBoardDownRequest)
      case CommunityBoardDownOff(id: Int)
    
    case CommunityNoticeDown(param: ComunityNoticeDownRequest)
      case CommunityNoticeDownOff(id: Int)
    
    
  case CommuntyBoardDetail(id: Int)
  case CommuntyNoticeDetail(id: Int)
    case CommuntyNoticeVoteDetail(id: Int)
  
  case CommuntyBoardComment(id: Int)
  case CommuntyNoticeComment(id: Int)
  
  case NoticeCommentRegister(param: RegistCommunityCommentRequest)
  case BoardCommentRegister(param: RegistCommunityBoardCommentRequest)
  
  case RegistCommunityBoard(param: RegistCommunityBoard)
  case RegistCommunityNotice(param: RegistCommunityBoard)
    case RegistCommunityNoticeVote(param: CommunityVote)
  
  case imageRegister(communityId: Int, imageList: [UIImage])
    case imageNoticeRegister(communityId: Int, imageList: [UIImage])
    case imageBoardRegister(communityId: Int, imageList: [UIImage])
    case imageRemove(id: [Int])
    case communityNoticeCommentRemove(id: Int)
  
  
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
    case .CommuntyJoin : return "/v1/communityJoiner/register"
    case .CommunityJoinerList : return "/v1/communityJoiner/list"
    case .CommunityJoinerUpdate : return "/v1/communityJoiner/update"
    case .CommuntyRegister : return "/v1/community/register"
    case .CommuntyUpdate : return "/v1/community/update"
    case .CommuntyList : return "/v1/community/list"
    case .CommuntyDetail : return "/v1/community/detail"
    case .CommuntyNotice : return "/v1/communityNotice/list"
    case .CommuntyBoard : return "/v1/communityBoard/list"
    case .CommuntyBoardDetail : return "/v1/communityBoard/detail"
    case .CommuntyNoticeDetail : return "/v1/communityNotice/detail"
    case .CommuntyBoardComment : return "/v1/communityBoardComment/list"
    case .CommuntyNoticeComment : return "/v1/communityNoticeComment/list"
    case .NoticeCommentRegister : return "/v1/communityNoticeComment/register"
    case .BoardCommentRegister : return "/v1/communityBoardComment/register"
    case .RegistCommunityBoard : return "/v1/communityBoard/register"
    case .RegistCommunityNotice : return "/v1/communityNotice/register"
    case .CommuntyNoticeVoteDetail : return "/v1/vote/list"
    case .RegistCommunityNoticeVote : return "/v1/vote/register"
    case .imageRegister : return "/v1/communityImage/register"
    case .imageNoticeRegister : return "/v1/communityNoticeImage/register"
    case .imageBoardRegister : return "/v1/communityBoardImage/register"
    case .imageRemove : return "/v1/communityImage/remove"
    case .CommuntyLike : return "/v1/communityLike/register"
    case .CommuntyDisLike : return "/v1/communityLike/remove"
    case .CommuntyInfoLike : return "/v1/communityNoticeLike/register"
    case .CommuntyInfoDisLike : return "/v1/communityNoticeLike/remove"
    case .CommunityBoardDown : return "/v1/communityBoardDown/register"
    case .CommunityBoardDownOff : return "/v1/communityBoardDown/remove"
    case .CommunityNoticeDown : return "/v1/communityNoticeDown/register"
    case .CommunityNoticeDownOff : return "/v1/communityNoticeDown/remove"
    case .communityNoticeCommentRemove : return "/v1/communityNoticeComment/remove"
    }
    
  }
  
  var method: Moya.Method {
    switch self {
    case .CommuntyDetail,
        .CommuntyList,
        .CommunityJoinerList,
        .CommuntyNotice,
        .CommuntyBoardDetail,
        .CommuntyNoticeDetail,
        .CommuntyBoardComment,
        .CommuntyNoticeComment,
        .CommuntyNoticeVoteDetail,
        .CommuntyBoard:
      return .get
    case .CommuntyJoin,
        .NoticeCommentRegister,
        .BoardCommentRegister,
        .RegistCommunityBoard,
        .imageRegister,
        .CommuntyRegister,
        .CommuntyLike,
        .CommuntyInfoLike,
        .CommunityBoardDown,
        .CommunityNoticeDown,
        .imageNoticeRegister,
        .RegistCommunityNoticeVote,
        .imageBoardRegister,
        .RegistCommunityNotice:
      return .post
    case .CommunityJoinerUpdate,
            .CommuntyUpdate:
      return .put
    case .CommuntyDisLike,
            .imageRemove,
            .CommunityBoardDownOff,
            .CommunityNoticeDownOff,
            .communityNoticeCommentRemove,
            .CommuntyInfoDisLike:
      return .delete
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  var task: Task {
    switch self {
    case .CommuntyNoticeVoteDetail(let id):
        return .requestParameters(parameters: ["communityNoticeId": id], encoding: URLEncoding.queryString)
      
    case .RegistCommunityNoticeVote(let param):
        return .requestJSONEncodable(param)
        
    case .CommuntyRegister(let param) :
      return .requestJSONEncodable(param)
      
    case .CommuntyJoin(let param) :
      return .requestJSONEncodable(param)
      
    case .CommunityJoinerList(let param) :
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
    case .CommunityJoinerUpdate(let id, let param) :
      return .requestCompositeParameters(bodyParameters: param.dictionary ?? [:], bodyEncoding: JSONEncoding.default, urlParameters: ["id": id])
        
    case .CommuntyUpdate(let id, let param) :
      return .requestCompositeParameters(bodyParameters: param.dictionary ?? [:], bodyEncoding: JSONEncoding.default, urlParameters: ["id": id])
        
    
    case .CommuntyLike(let param) :
        return .requestJSONEncodable(param)
    case .CommuntyDisLike(let id) :
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
    case .communityNoticeCommentRemove(let id) :
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        
    case .CommunityBoardDown(let param) :
        return .requestJSONEncodable(param)
    case .CommunityBoardDownOff(let id) :
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        
    case .CommuntyInfoLike(let param) :
        return .requestJSONEncodable(param)
    case .CommuntyInfoDisLike(let id) :
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        
        
    case .CommunityNoticeDown(let param) :
        return .requestJSONEncodable(param)
    case .CommunityNoticeDownOff(let id) :
      return .requestParameters(parameters: ["communityNoticeId": id], encoding: URLEncoding.queryString)
        
    case .imageRemove(let id):
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
      
    case .CommuntyDetail(let param) :
        return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
    case .CommuntyList(let param) :
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
    case .CommuntyNotice(let param) :
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
    case .CommuntyBoard(let param) :
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
    case .CommuntyBoardDetail(let id) :
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
      
    case .CommuntyNoticeDetail(let id) :
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
      
    case .CommuntyBoardComment(let id) :
      return .requestParameters(parameters: ["communityBoardId": id], encoding: URLEncoding.queryString)
      
    case .CommuntyNoticeComment(let id) :
      return .requestParameters(parameters: ["communityNoticeId": id], encoding: URLEncoding.queryString)
      
    case .NoticeCommentRegister(let param) :
      return .requestJSONEncodable(param)
      
    case .BoardCommentRegister(let param) :
      return .requestJSONEncodable(param)
      
    case .RegistCommunityBoard(let param) :
      return .requestJSONEncodable(param)
      
    case .RegistCommunityNotice(let param) :
      return .requestJSONEncodable(param)
      
    case .imageRegister(let foodId, let imageList):
      let multipartList = imageList.map { image in
        return MultipartFormData(provider: .data(image.jpegData(compressionQuality: 0.9)!), name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
      }
      return .uploadCompositeMultipart(
        multipartList,
        urlParameters: ["communityId": foodId]
      )
    case .imageNoticeRegister(let foodId, let imageList):
      let multipartList = imageList.map { image in
        return MultipartFormData(provider: .data(image.jpegData(compressionQuality: 0.9)!), name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
      }
      return .uploadCompositeMultipart(
        multipartList,
        urlParameters: ["communityNoticeId": foodId]
      )
    case .imageBoardRegister(let foodId, let imageList):
      let multipartList = imageList.map { image in
        return MultipartFormData(provider: .data(image.jpegData(compressionQuality: 0.9)!), name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
      }
      return .uploadCompositeMultipart(
        multipartList,
        urlParameters: ["communityBoardId": foodId]
      )
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

struct ComunityNoticeRequest: Codable {
  let isReport: Bool?
  let communityId: Int?
  
  init(
    isReport: Bool? = nil,
    communityId: Int? = nil
  ) {
    self.isReport = isReport
    self.communityId = communityId
  }
  
}
struct ComunityLikeRequest: Codable {
  let isLike: Bool?
  let communityId: Int?
}
struct ComunityInfoLikeRequest: Codable {
  let isLike: Bool?
  let communityNoticeId: Int?
}
struct ComunityBoardDownRequest: Codable {
  let communityBoardId: Int?
}
struct ComunityNoticeDownRequest: Codable {
  let communityNoticeId: Int?
}

struct RegistCommunityBoard: Codable {
  let communityId: Int
  let title: String
  let content: String
}

struct JoinCommunity: Codable {
  let communityId: Int
  
}

struct CommunityJoinerUpdateRequest: Codable {
  let authorityNotice: Bool
  let authorityBoard: Bool
  let authorityChat: Bool
  let authorityDelete: Bool
  let status: String?
}

struct RegistCommunityCommentRequest: Codable {
  let communityNoticeId: Int
  let content: String
  let communityNoticeCommentId: Int?
}

struct RegistCommunityBoardCommentRequest: Codable {
  let communityBoardId: Int
  
  let content: String
  let communityBoardCommentId: Int?
}

struct RegistCommunityRegister: Codable {
  let isSecret: Bool
  let name: String
  let content: String
  let villageId: Int
  let category: String
}
struct categoryListRequest: Codable {
  let page: Int?
  let limit: Int?
  let category: CommunityCategory?
  let myList: String?
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
    page: Int? = nil,
    limit: Int? = nil,
    category: CommunityCategory? = nil,
    myList: String? = nil,
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
    self.page = page
    self.limit = limit
  }
  
}
struct communityDetailRequest: Codable {
  let latitude: String?
  let longitude: String?
  let id: Int?
  
  init(
    latitude: String? = nil,
    longitude: String? = nil,
    id: Int? = nil
  ) {
    self.latitude = latitude
    self.longitude = longitude
    self.id = id
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

