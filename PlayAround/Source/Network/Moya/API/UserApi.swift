//
//  UserApi.swift
//  PlayAround
//
//  Created by haon on 2022/04/20.
//

import Foundation
import Moya 
import UIKit

enum UserAPI {
  
  case userInfo(param: UserInfoRequest)
  case userList(search: String?)
  case userUpdate(param: UserUpdateRequest)
  case userLogout
  case userWithDrawal
  case userFileRegister(image: UIImage)
  case userFileDelete
}

extension UserAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .userInfo:
      return "/v1/user/info"
    case .userList:
      return "/v1/user/list"
    case .userUpdate:
      return "/v1/user/update"
    case .userLogout:
      return "/v1/user/logout"
    case .userWithDrawal:
      return "/v1/user/withDrawal"
    case .userFileRegister:
      return "/v1/user/file/register"
    case .userFileDelete:
      return "/v1/user/file/Delete"
    }
  }
  
  var method: Moya.Method {
    switch self {
      
    case .userInfo,
        .userList,
        .userLogout:
      return .get
      
    case .userFileRegister:
      return .post
      
    case .userUpdate:
      return .put
      
    case .userWithDrawal,
        .userFileDelete:
      return .delete
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
    case .userInfo(let id):
      return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
      
    case .userList(let search):
      return .requestParameters(parameters: ["search": search], encoding: URLEncoding.queryString)
      
    case .userUpdate(let param):
      return .requestParameters(parameters: param.dictionary ?? [:], encoding: URLEncoding.queryString)
      
    case .userLogout,
        .userWithDrawal,
        .userFileDelete:
      return .requestPlain
      
    case .userFileRegister(let image):
      let multipart = MultipartFormData(provider: .data(image.jpegData(compressionQuality: 0.9)!), name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
      return .uploadMultipart([multipart])
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

struct UserInfoRequest: Codable {
  let id: Int?
  
  init(
    id: Int? = nil
  ) {
    self.id = id
  }
}

struct UserInfoResponse: Codable {
  let statusCode: Int
  let message: String
  let data: User
}

// MARK: - User
struct User: Codable {
  let id: Int
  let loginId, tel: String
  let thumbnail: String?
  let name, role: String
  let active: Bool
  let followings, followers: [Follow]?
  let isFollowing: Bool
  let foodLevel, usedLevel, communityLevel: Int?
}

// MARK: - Follow
struct Follow: Codable {
  let id: Int
  let name: String?
  let thumbnail: String?
  let isFollowing: Bool
}
