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
  let list: [CommuintyList]
}

struct CommuintyList: Codable {
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
struct CommunityNoticeResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [CommunityNotice]?
}
struct CommunityNotice: Codable {
  let id,communityId,likeCount,dislikeCount: Int
  let title,createdAt, content: String
}
struct CommunityBoardResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [CommunityBoard]?
}
struct CommunityBoard: Codable {
  let id,communityId,likeCount,dislikeCount: Int
  let outCount: Int?
  let isOut: Bool
  let title,createdAt, content: String
}
struct CommunityInfoDetailResponse: Codable {
  let statusCode: Int
  let message: String
  let data: CommunityInfo
}

// MARK: - DataClass
struct CommunityInfo: Codable {
  let id, communityId: Int
  let title, content, createdAt: String
  let likeCount, dislikeCount: Int
  let  authorityDelete, isOut: Bool
  let isLike: Bool?
  let outCount: Int
  let user: User
  let images: [Image?]
  let isReport: Bool
}

struct CommunityCommentResponse: Codable {
    let statusCode: Int
    let message: String
    let list: [Comment]
}

// MARK: - List
struct Comment: Codable {
  let id, userId: Int
  let  communityBoardId,CommunityNoticeId: Int?
    let content: String
    let depth: Int
    let createdAt: String
//    let user: [User]
}
