//
//  ChatAPI.swift
//  PlayAround
//
//  Created by haon on 2022/06/27.
//

import Foundation
import Moya

enum ChatAPI {
  case roomRegister(param: RegistChatRoomRequest)
  
  case roomJoinRegister(param: RegistChatRoomJoinRequest)
    case roomList(communityId: Int)
  case roomJoinRemove(chatRoomId: Int, userId: Int, diff: ChatRommJoinRemoveDiff)
  
  case chatMessageFileRegister(chatRoomId: Int, image: UIImage)
}

extension ChatAPI: TargetType {
  public var baseURL: URL {
    switch self {
    default:
      return URL(string: ApiEnvironment.baseUrl)!
    }
  }
  
  var path: String {
    switch self {
    case .roomRegister:
      return "/v1/chatRoom/register"
    case .roomJoinRegister:
      return "/v1/chatRoomJoin/list"
    case .roomList:
      return "/v1/chatRoom/list"
    case .roomJoinRemove:
      return "/v1/chatRoom/remove"
    case .chatMessageFileRegister:
      return "/v1/chatMessage/file/register"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .roomRegister,
        .roomJoinRegister,
        .chatMessageFileRegister:
      return .post
    case .roomList:
        return .get
    case .roomJoinRemove:
      return .delete
    }
  }
  
  var sampleData: Data {
    return "!!".data(using: .utf8)!
  }
  
  var task: Task {
    switch self {
        
    case .roomList(let Id):
        return .requestParameters(parameters: ["communityId": Id], encoding: URLEncoding.queryString)
    case .roomRegister(let param):
      return .requestJSONEncodable(param)
    case .roomJoinRegister(let param):
      return .requestJSONEncodable(param)
    case .roomJoinRemove(let chatRoomId, let userId, let diff):
      return .requestParameters(parameters: ["chatRoomId": chatRoomId, "userId": userId, "diff": diff], encoding: URLEncoding.queryString)
    case .chatMessageFileRegister(let chatRoomId, let image):
      let multipart = MultipartFormData(provider: .data(image.jpegData(compressionQuality: 0.3)!), name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
      return .uploadCompositeMultipart([multipart], urlParameters: ["chatRoomId": chatRoomId])
    }
  }
  
  var headers: [String : String]? {
    switch self {
    default:
      if let token = DataHelperTool.token {
        return ["Content-type": "application/json", "Authorization": token]
      } else {
        return ["Content-type": "application/json"]
      }
    }
  }
  
}

struct RegistChatRoomRequest: Codable {
  let title: String?
  let communityId: Int?
  let foodId: Int?
  let usedId: Int?
  let userId: Int?
  
  init(
    title: String? = nil,
    communityId: Int? = nil,
    foodId: Int? = nil,
    usedId: Int? = nil,
    userId: Int? = nil
  ) {
    self.title = title
    self.communityId = communityId
    self.foodId = foodId
    self.usedId = usedId
    self.userId = userId
  }
}

struct RegistChatRoomJoinRequest: Codable {
  let userId: [Int]
  let chatRoomId: Int
}

enum ChatRommJoinRemoveDiff: String, Codable {
  case 강퇴
  case 해제
}

// MARK: - RegistChatRoomResponse
struct RegistChatRoomResponse: Codable {
  let statusCode: Int
  let message: String
  let data: Data
  
  // MARK: - Data
  struct Data: Codable {
    let id: Int
    let userId: Int
    let updatedAt: String
    let createdAt: String
  }
}

struct RegistChatMessageImageResponse: Codable {
  let statusCode: Int
  let message: String
  let data: Data
  
  // MARK: - Data
  struct Data: Codable {
    let id: Int
    let message: String
    let userId: Int
      let type: String
  }
}
