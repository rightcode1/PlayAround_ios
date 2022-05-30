//
//  AuthResponse.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/13.
//

import Foundation

struct FindIdResponse: Codable {
  let statusCode: Int
  let message: String
  let data: findID?
}

struct findID: Codable {
  let loginId: String
}
