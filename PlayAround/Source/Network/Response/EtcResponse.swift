//
//  EtcResponse.swift
//  BARO
//
//  Created by ldong on 2018. 1. 26..
//  Copyright © 2018년 weplanet. All rights reserved.
//

import Foundation

struct ErrorMessage: Decodable {
  var errorLog: [String]?
  var errorCode: String?
}

struct BoolResponse: Codable {
  var data: Bool?
}

struct ResultResponse: Codable {
  var result: Bool
  var result_msg: String
}

struct DefaultResponse: Codable {
  var statusCode: Int
  var message: String
}
struct LoginResponse: Codable {
  let statusCode: Int
  let token: String
  let message: String
}

struct DefaultCodeResponse: Codable {
  let statusCode: Int
  let message: String
}

struct DefaultIDResponse: Codable {
  let statusCode: Int
  let message: String
  let data: DefaultID?
}

struct MyInfoResponse: Codable {
  let statusCode: Int
  let message: String
  let data: myinfo?
}

struct myinfo: Codable {
  let id : Int
  let loginId, tel, name, role: String
}

struct DefaultID: Codable {
  let id: Int
    let communityId :Int?
}

struct Image: Codable {
  let id: Int
  let name: String
}

struct AdvertiseResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [AdvertiseList]
}

struct AdvertiseList: Codable {
  let id : Int
  let title, diff : String
  let url, thumbnail, image: String?
}

struct NotifyListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [NotifyList]
}

struct NotifyList: Codable {
  let id, userId, data : Int
  let userThumbnail,thumbnail, message, diff, createdAt: String?
}

enum StringAndInt: Codable {
  case integer(Int)
  case string(String)
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let x = try? container.decode(Int.self) {
      self = .integer(x)
      return
    }
    if let x = try? container.decode(String.self) {
      self = .string(x)
      return
    }
    throw DecodingError.typeMismatch(StringAndInt.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for StringAndInt"))
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .integer(let x):
      try container.encode(x)
    case .string(let x):
      try container.encode(x)
    }
  }
}
