//
//  FoodApi.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/18.
//

import Foundation
import Moya

enum FoodApi {
  
  case foodList(param: FoodListRequest)
  case foodDetail(id: Int)
  
  case register(param: FoodRegistRequest)
  case update(id: Int, param: FoodRegistRequest)
  case remove(id: Int)
  
  case imageRegister(foodId: Int, imageList: [UIImage])
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
    case .foodDetail : return "/v1/food/detail"
    case .register : return "/v1/food/register"
    case .update : return "/v1/food/update"
    case .remove : return "/v1/food/remove"
    case .imageRegister : return "/v1/foodImage/register"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .foodList,
        .foodDetail:
      return .get
    case .register,
        .imageRegister:
      return .post
    case .update:
      return .put
    case .remove:
      return .delete
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .foodList(let param):
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
    case .foodDetail(let id):
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
    case .register(let param):
      return .requestJSONEncodable(param)
    case .update(let id, let param):
      return .requestCompositeParameters(bodyParameters: param.dictionary ?? [:], bodyEncoding: JSONEncoding.default, urlParameters: ["id": id])
    case .remove(let id):
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
    case .imageRegister(let foodId, let imageList):
        let multipartList = imageList.map { image in
          return MultipartFormData(provider: .data(image.jpegData(compressionQuality: 0.5)!), name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
        }
        return .uploadCompositeMultipart(
          multipartList,
          urlParameters: ["foodId": foodId]
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


struct FoodListRequest: Codable {
  let category: FoodCategory?
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
    category: FoodCategory? = nil,
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


// MARK: - FoodDetailResponse
struct FoodDetailResponse: Codable {
  let statusCode: Int
  let message: String
  let data: FoodDetailData?
}

// MARK: - FoodDetailData
struct FoodDetailData: Codable {
  let id, userId: Int
  let category: FoodCategory
  let name, content: String
  let price: Int
  let allergy: [FoodAllergy]
  let statusSale: Bool?
  let viewCount: Int
  let createdAt: String
  let wishCount: Int
  let isWish: Bool
  let isLike: Bool?
  let likeCount, dislikeCount: Int
  let images: [Image]
  let user: User
  let address: String
  let villageId: Int
  let status: FoodStatus
  let userCount: Int?
  let dueDate: String?
  let requestCount: Int?
  let isRequest: Bool
  let foodUsers: [User]
  let hashtag: [String]
  let isReport: Bool
}


// MARK: - FoodRegistRequest
struct FoodRegistRequest: Codable {
  let category: FoodCategory
  let name, content: String
  let price: Int
  let hashtag: [String]
  let allergy: [FoodAllergy]
  let villageId: Int
  let userCount: Int?
  let dueDate: String?
  let status: FoodStatus
}
