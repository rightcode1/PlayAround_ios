//
//  FoodResponse.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/18.
//

import Foundation

// MARK: - Welcome
struct FoodResponse: Codable {
    let statusCode: Int
    let message: String
    let list: [FoodList]
}

// MARK: - List
struct FoodList: Codable {
    let id: Int
    let category, name: String?
//    let price, wishCount: Int
//    let isWish: Bool
//    let isLike: Bool?
//    let likeCount, dislikeCount: Int
//    let statusSale: Bool
//    let user: [User]
//    let address: String
//    let viewCount, villageID, commentCount: Int
//    let status: String
//    let requestCount: Int
//    let userCount, dueDate: String?
//    let isRequest: Bool
//    let hashtag: [String?]
//    let isReport: Bool
}

