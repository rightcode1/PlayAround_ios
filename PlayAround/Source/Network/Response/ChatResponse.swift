//
//  ChatResponse.swift
//  PlayAround
//
//  Created by haon on 2022/06/27.
//

import Foundation

struct ChatLoginResponse: Codable {
  let result: Bool
  let message: String
}

// MARK: - ChatRoomListResponse
struct ChatRoomListResponse: Codable {
  let result: Bool
  let list: [ChatRoomData]
}

// MARK: - ChatRoomData
struct ChatRoomData: Codable {
  var id: Int?
  var message, name, from: String?
  var thumbnail: String?
  var userId: Int?
  var foodId: Int?
  var usedId: Int?
  var communityId: Int?
  var userCount: Int?
  var count: Int?
  var updatedAt: String?
  var isSecret: Int?
  
  init(dict: [String:Any]) {
    if let obj = dict["id"] {
      self.id = obj as? Int
    }
    
    if let obj = dict["message"] {
      self.message = obj as? String
    }
    
    if let obj = dict["name"] {
      self.name = obj as? String
    }
    
    if let obj = dict["from"] {
      self.from = obj as? String
    }
    
    if let obj = dict["thumbnail"] {
      self.thumbnail = obj as? String
    }
    
    if let obj = dict["userId"] {
      self.userId = obj as? Int
    }
    
    if let obj = dict["foodId"] {
      self.foodId = obj as? Int
    }
    
    if let obj = dict["usedId"] {
      self.usedId = obj as? Int
    }
    
    if let obj = dict["communityId"] {
      self.communityId = obj as? Int
    }
    
    if let obj = dict["userCount"] {
      self.userCount = obj as? Int
    }
    
    if let obj = dict["count"] {
      self.count = obj as? Int
    }
    
    if let obj = dict["updatedAt"] {
      self.updatedAt = obj as? String
    }
    
    if let obj = dict["isSecret"] {
      self.isSecret = obj as? Int
    }
  }
}

// MARK: - MessageListResponse
struct MessageListResponse: Codable {
  let result: Bool
  let message: String
  let isMaster: Bool
  let data: [MessageData]
}

enum MessageType: String, Codable {
  case message = "message"
  case file = "file"
}

// MARK: - MessageData
struct MessageData: Codable {
  var id: Int?
  var type: String?
  var message, userName: String?
  var thumbnail: String?
  var userId: Int?
  var readAt: String?
  var readCount: Int?
  var createdAt: String?
  
  init(dict: [String:Any]) {
    if let obj = dict["id"] {
      self.id = obj as? Int
    }
    
    if let obj = dict["type"] {
      self.type = obj as? String
    }
    
    if let obj = dict["message"] {
      self.message = obj as? String
    }
    
    if let obj = dict["userName"] {
      self.userName = obj as? String
    }
    
    if let obj = dict["thumbnail"] {
      self.thumbnail = obj as? String
    }
    
    if let obj = dict["userId"] {
      self.userId = obj as? Int
    }
    
    if let obj = dict["readAt"] {
      self.readAt = obj as? String
    }
    
    if let obj = dict["readCount"] {
      self.readCount = obj as? Int
    }
    
    if let obj = dict["createdAt"] {
      self.createdAt = obj as? String
    }
  }
}


struct ChatUserListResponse: Codable {
  var result: Bool
  var message: String
  var data: [ChatUserInfo]
}

struct ChatUserInfo: Codable {
  var id: Int
  var thumbnail: String?
  var loginId: String
  var tel: String
  var name: String
  var role: Int
  var active: Bool
  var isFollowing: Bool
}


