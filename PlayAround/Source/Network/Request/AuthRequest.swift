//
//  AuthRequest.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/11.
//

import Foundation

struct SocialLoginRequest: Codable {
  let loginId: String
  let password: String?
  let provider: SocialLoginDiff
  let name: String?
}

enum SocialLoginDiff: String, Codable {
  case kakao
  case apple
}

struct JoinRequest: Codable {
  let loginId: String
  let password: String
  let tel: String
  let name: String
}

struct CheckloginId: Codable {
  var loginId: String
  
  enum CodingKeys: String, CodingKey {
    case loginId = "loginId"
  }
}

enum SendCodeDiff: String, Codable {
  case join = "join"
  case find = "find"
  case update = "update"
}

struct SendCodeRequest: Codable {
  var tel: String
  var diff: SendCodeDiff
}

struct FindMyIdRequest: Codable {
  var tel: String
  
  enum CodingKeys: String, CodingKey {
    case tel = "tel"
  }
}

struct CheckphoneCodeRequest: Codable {
  let tel: String
  let confirm: String
}

struct ChangePasswordRequest: Codable {
  var loginId: String
  var password: String
  var tel: String
  
  enum CodingKeys: String, CodingKey {
    case loginId = "loginId"
    case password = "password"
    case tel = "tel"
  }
  
}
struct LoginRequest: Codable {
  var loginId: String
  var password: String
  let deviceId: String 
}
