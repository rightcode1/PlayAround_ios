//
//  usedResponse.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/16.
//

import Foundation

struct UsedResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [UsedList]
}

// MARK: - List
struct UsedList: Codable {
  let id: Int
  let category, name: String
  let price, wishCount: Int
  let isWish, statusSale: Bool
  let isLike: Bool?
  let likeCount, dislikeCount: Int
  let user: User
  let address: String
  let thumbnail: String?
  let villageId, viewCount, commentCount: Int
  let hashtag: [String]
  let isReport: Bool
}


