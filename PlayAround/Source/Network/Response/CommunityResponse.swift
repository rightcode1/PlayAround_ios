//
//  HomeComunity.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/16.
//

import Foundation


struct CommunityResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [commuintyList]
}

struct commuintyList: Codable {
  let id: Int
  let isSecret: Bool
  let name, content: String
  let villageId, userId: Int
  let createdAt, category: String
  let likeCount, dislikeCount, people: Int
  let distance: Double
  let isLike: Bool?
  let userName, address: String
  let images: [Image]
}

struct CommuintyDetailResponse: Codable {
    let statusCode: Int
    let message: String
    let data: CommunityDetail
}

// MARK: - DataClass
struct CommunityDetail: Codable {
    let id: Int
    let isSecret: Bool
    let name, content: String
    let villageId, likeCount, dislikeCount: Int
  let distance: Double
    let people: Int
    let isJoin: Bool
    let joinStatus: String
    let isLike: Bool?
    let images: [Image]
    let user: User
    let category: String
    let authorityNotice, authorityBoard, authorityChat, authorityDelete: Bool
    let userName, address: String
    let noticeCount, boardCount, chatRoomCount: Int

}
