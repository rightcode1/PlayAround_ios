//
//  HomeComunity.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/16.
//

import Foundation

struct CommunityRowResponse: Codable {
  let statusCode: Int
  let message: String
  let list: CommunityRow
}
struct CommunityRow: Codable {
  let rows: [CommuintyList]
}


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
  let user: User
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
  let user: User
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
    let user: User
}

struct CommunityJoinResponse: Codable {
  let statusCode: Int
  let message: String
  let data: CommunityJoin
}
struct CommunityJoin: Codable {
  let userId,communityId,id: Int
  let authorityNotice: Bool
  let authorityBoard: Bool
  let authorityChat: Bool
  let authorityDelete: Bool
  let master: Bool
  let updatedAt,createdAt, status: String
  
}
struct CommunityJoinerResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [CommunityJoiner]
}
struct CommunityJoiner: Codable {
  let id: Int
  let authorityNotice: Bool
  let authorityBoard: Bool
  let authorityChat: Bool
  let authorityDelete: Bool
  let master: Bool
  let createdAt, status: String
  let user : User
}
struct CommunityVote: Codable {
  var communityNoticeId: Int
    var title: String
    var endDate: String
    var overlap: Bool
    var choices : [Choice]
}
struct Choice: Codable {
    var content: String
}
struct CommunityVoteResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [CommunityVoteList]
}
struct CommunityVoteList: Codable {
    var id: Int
    var communityNoticeId: Int
    var title: String
    var endDate: String
    var overlap: Bool
    var choice : [choice]
}

struct choice: Codable {
    var id: Int
    var count: Int
    var content: String
    var isCheck: Bool
}

