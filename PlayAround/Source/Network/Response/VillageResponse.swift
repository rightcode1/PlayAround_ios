//
//  villageResponse.swift
//  PlayAround
//
//  Created by 이남기 on 2022/06/22.
//

import Foundation

struct VillageListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [village]
}

struct village: Codable {
  let id: Int
  let address: String
  let isCert: Bool
  let certDate: String?
  var isselect: Bool? = false
}
