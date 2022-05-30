//
//  UserApi.swift
//  PlayAround
//
//  Created by haon on 2022/04/20.
//

import Foundation
import Moya 
import UIKit

enum UserApi {
  
  case userinfo(id: Int)
  case userList(search: String?)
  case userUpdate(param: UserUpdateRequest)
  case userLogout
  case userWithDrawal
  case userFileRegister(image: UIImage)
  case userFileDelete
}

extension UserApi: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .userinfo:
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
      
    case .userinfo,
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
    case .userinfo(let id):
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

