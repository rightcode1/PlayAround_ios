//
//  UsedAPI.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/18.
//

import Foundation
import Moya

enum UsedAPI {
  case list(param: UsedListRequest)
  case detail(id: Int)
  
  case register(param: RegistUsedRequest)
  case update(id: Int, param: RegistUsedRequest)
  case remove(id: Int)
  
  case imageRegister(usedId: Int, imageList: [UIImage])
  
  case likeRegister(param: RegistUsedLikeRequest)
  case likeRemove(id: Int)
  
  case wishRegister(param: RegistUsedWishRequest)
  case wishRemove(usedId: Int)
  
  case commentList(usedId: Int)
  case commentRegister(param: RegistUsedCommentRequest)
}
extension UsedAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  
  var path: String {
    switch self {
    case .list : return "/v1/used/list"
    case .detail : return "/v1/used/detail"
    case .register : return "/v1/used/register"
    case .update : return "/v1/used/update"
    case .remove : return "/v1/used/remove"
    case .imageRegister : return "/v1/usedImage/register"
      
    case .likeRegister : return "/v1/usedLike/register"
    case .likeRemove : return "/v1/usedLike/remove"
      
    case .wishRegister : return "/v1/usedWish/register"
    case .wishRemove : return "/v1/usedWish/remove"
      
    case .commentList : return "/v1/usedComment/list"
    case .commentRegister : return "/v1/usedComment/register"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .list,
        .detail,
        .commentList:
      return .get
    case .register,
        .imageRegister,
        .likeRegister,
        .wishRegister,
        .commentRegister:
      return .post
    case .update:
      return .put
    case .remove,
        .likeRemove,
        .wishRemove:
      return .delete
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .list(let param):
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
    case .detail(let id):
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
    case .register(let param):
      return .requestJSONEncodable(param)
    case .update(let id, let param):
      return .requestCompositeParameters(bodyParameters: param.dictionary ?? [:], bodyEncoding: JSONEncoding.default, urlParameters: ["id": id])
    case .remove(let id):
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
    case .imageRegister(let usedId, let imageList):
      let multipartList = imageList.map { image in
        return MultipartFormData(provider: .data(image.jpegData(compressionQuality: 0.5)!), name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
      }
      return .uploadCompositeMultipart(
        multipartList,
        urlParameters: ["usedId": usedId]
      )
    case .likeRegister(let param):
      return .requestJSONEncodable(param)
    case .likeRemove(let id):
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
    case .wishRegister(let param):
      return .requestJSONEncodable(param)
    case .wishRemove(let usedId):
      return .requestParameters(parameters: ["usedId": usedId], encoding: URLEncoding.queryString)
      
    case .commentList(let usedId):
      return .requestParameters(parameters: ["usedId": usedId], encoding: URLEncoding.queryString)
    case .commentRegister(let param):
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

struct UsedListRequest: Codable {
  let category: UsedCategory?
  let search: String?
  let statusSale: String?
  let si: String?
  let gu: String?
  let dong: String?
  let villageId: Int?
  let hashtag: String?
  let isWish: Bool?
  let userId: Int?
  let isReport: String?
  let sort: FoodSort?
  
  init(
    category: UsedCategory? = nil,
    search: String? = nil,
    statusSale: String? = nil,
    si: String? = nil,
    gu: String? = nil,
    dong: String? = nil,
    villageId: Int? = nil,
    hashtag: String? = nil,
    isWish: Bool? = nil,
    userId: Int? = nil,
    isReport: String? = nil,
    sort: FoodSort? = nil
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
    self.sort = sort
  }
  
}

enum statusSale: String, Codable {
  case 판매중
  case 판매완료
}

// MARK: - UsedListResponse
struct UsedListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [UsedListData]
}

// MARK: - UsedListData
struct UsedListData: Codable {
  let id: Int
  let thumbnail: String?
  let category: UsedCategory
  let name: String
  let price, wishCount: Int
  let isWish, statusSale: Bool
  let isLike: Bool?
  let likeCount, dislikeCount: Int
  let user: User
  let address: String
  let villageId, viewCount, commentCount: Int
  let hashtag: [String]
  let isReport: Bool
}

// MARK: - UsedDetailResponse
struct UsedDetailResponse: Codable {
  let statusCode: Int
  let message: String
  let data: UsedDetailData?
}

// MARK: - UsedDetailData
struct UsedDetailData: Codable {
  let id, userId: Int
  let category: UsedCategory
  let name, content: String
  let price: Int
  let statusSale: Bool
  let viewCount: Int
  let createdAt: String
  let wishCount: Int
  let isWish: Bool
  let images: [Image]
  let user: User
  let isLike: Bool?
  let likeCount, dislikeCount: Int
  let address: String
  let villageId: Int
  let hashtag: [String]
  let isReport: Bool
}

struct RegistUsedLikeRequest: Codable {
  let isLike: Bool
  let usedId: Int
}

struct RegistUsedWishRequest: Codable {
  let usedId: Int
}

// MARK: - UsedCommentListResponse
struct UsedCommentListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [UsedCommentListData]
}

// MARK: - UsedCommentListData
struct UsedCommentListData: Codable {
  let id, userId, usedId: Int
  let content: String
  let depth: Int
  let createdAt: String
  let user: User
}

struct RegistUsedCommentRequest: Codable {
  let usedId: Int
  let content: String
  let usedCommentId: Int?
}

struct RegistUsedRequest: Codable {
  let category: UsedCategory
  let name: String
  let content: String
  let price: Int
  let villageId: Int
  let hashtag: [String]
}
