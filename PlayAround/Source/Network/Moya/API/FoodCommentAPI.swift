//
//  FoodCommentAPI.swift
//  PlayAround
//
//  Created by haon on 2022/06/02.
//

import Foundation

// MARK: - FoodCommentListResponse
struct FoodCommentListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [FoodCommentListData]
}

// MARK: - FoodCommentListData
struct FoodCommentListData: Codable {
  let id, userId, foodId: Int
  let content: String
  let depth: Int
  let createdAt: String
  let user: User
}
