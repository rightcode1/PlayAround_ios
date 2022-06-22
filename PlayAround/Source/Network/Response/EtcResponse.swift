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
