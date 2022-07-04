//
//  Food+Enum.swift
//  PlayAround
//
//  Created by haon on 2022/06/13.
//

import Foundation
import UIKit

enum FoodCategory: String, Codable {
  case 전체
  case 국물
  case 찜
  case 볶음
  case 나물
  case 베이커리
  case 저장
  
  func onImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "sideCategoryFullColorOn1") ?? UIImage()
    case .국물:
      return UIImage(named: "sideDishCategoryFullColorOn2") ?? UIImage()
    case .찜:
      return UIImage(named: "sideDishCategoryFullColorOn3") ?? UIImage()
    case .볶음:
      return UIImage(named: "sideDishCategoryFullColorOn4") ?? UIImage()
    case .나물:
      return UIImage(named: "sideDishCategoryFullColorOn5") ?? UIImage()
    case .베이커리:
      return UIImage(named: "sideDishCategoryFullColorOn6") ?? UIImage()
    case .저장:
      return UIImage(named: "sideDishCategoryFullColorOn7") ?? UIImage()
    }
  }
  
  func offImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "sideCategoryFullColorOff1") ?? UIImage()
    case .국물:
      return UIImage(named: "sideDishCategoryFullColorOff2") ?? UIImage()
    case .찜:
      return UIImage(named: "sideDishCategoryFullColorOff3") ?? UIImage()
    case .볶음:
      return UIImage(named: "sideDishCategoryFullColorOff4") ?? UIImage()
    case .나물:
      return UIImage(named: "sideDishCategoryFullColorOff5") ?? UIImage()
    case .베이커리:
      return UIImage(named: "sideDishCategoryFullColorOff6") ?? UIImage()
    case .저장:
      return UIImage(named: "sideDishCategoryFullColorOff7") ?? UIImage()
    }
  }
  
  func onRegistImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "sideCategoryFullColorOn1") ?? UIImage()
    case .국물:
      return UIImage(named: "sideDishCategoryRegistOn1") ?? UIImage()
    case .찜:
      return UIImage(named: "sideDishCategoryRegistOn2") ?? UIImage()
    case .볶음:
      return UIImage(named: "sideDishCategoryRegistOn3") ?? UIImage()
    case .나물:
      return UIImage(named: "sideDishCategoryRegistOn4") ?? UIImage()
    case .베이커리:
      return UIImage(named: "sideDishCategoryRegistOn5") ?? UIImage()
    case .저장:
      return UIImage(named: "sideDishCategoryRegistOn6") ?? UIImage()
    }
  }
  
  func offRegistImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "sideCategoryRegistOff1") ?? UIImage()
    case .국물:
      return UIImage(named: "sideDishCategoryRegistOff1") ?? UIImage()
    case .찜:
      return UIImage(named: "sideDishCategoryRegistOff2") ?? UIImage()
    case .볶음:
      return UIImage(named: "sideDishCategoryRegistOff3") ?? UIImage()
    case .나물:
      return UIImage(named: "sideDishCategoryRegistOff4") ?? UIImage()
    case .베이커리:
      return UIImage(named: "sideDishCategoryRegistOff5") ?? UIImage()
    case .저장:
      return UIImage(named: "sideDishCategoryRegistOff6") ?? UIImage()
    }
  }
}

enum FoodAllergy: String, Codable {
  case 없음
  case 갑각류
  case 생선
  case 메밀복숭아 = "메밀/복숭아"
  case 견과류
  case 달걀
  case 우유
  
  func onImage() -> UIImage {
    switch self {
    case .없음:
      return UIImage(named: "foodAllergyDetailImageOn1") ?? UIImage()
    case .갑각류:
      return UIImage(named: "foodAllergyDetailImageOn2") ?? UIImage()
    case .생선:
      return UIImage(named: "foodAllergyDetailImageOn3") ?? UIImage()
    case .메밀복숭아:
      return UIImage(named: "foodAllergyDetailImageOn4") ?? UIImage()
    case .견과류:
      return UIImage(named: "foodAllergyDetailImageOn5") ?? UIImage()
    case .달걀:
      return UIImage(named: "foodAllergyDetailImageOn6") ?? UIImage()
    case .우유:
      return UIImage(named: "foodAllergyDetailImageOn7") ?? UIImage()
    }
  }
  
  func offImage() -> UIImage {
    switch self {
    case .없음:
      return UIImage(named: "foodAllergyDetailImageOff1") ?? UIImage()
    case .갑각류:
      return UIImage(named: "foodAllergyDetailImageOff2") ?? UIImage()
    case .생선:
      return UIImage(named: "foodAllergyDetailImageOff3") ?? UIImage()
    case .메밀복숭아:
      return UIImage(named: "foodAllergyDetailImageOff4") ?? UIImage()
    case .견과류:
      return UIImage(named: "foodAllergyDetailImageOff5") ?? UIImage()
    case .달걀:
      return UIImage(named: "foodAllergyDetailImageOff6") ?? UIImage()
    case .우유:
      return UIImage(named: "foodAllergyDetailImageOff7") ?? UIImage()
    }
  }
  
  func onRegistImage() -> UIImage {
    switch self {
    case .없음:
      return UIImage(named: "foodAllergyRegistImageOn1") ?? UIImage()
    case .갑각류:
      return UIImage(named: "foodAllergyRegistImageOn2") ?? UIImage()
    case .생선:
      return UIImage(named: "foodAllergyRegistImageOn3") ?? UIImage()
    case .메밀복숭아:
      return UIImage(named: "foodAllergyRegistImageOn4") ?? UIImage()
    case .견과류:
      return UIImage(named: "foodAllergyRegistImageOn5") ?? UIImage()
    case .달걀:
      return UIImage(named: "foodAllergyRegistImageOn6") ?? UIImage()
    case .우유:
      return UIImage(named: "foodAllergyRegistImageOn7") ?? UIImage()
    }
  }
  
  func offRegistImage() -> UIImage {
    switch self {
    case .없음:
      return UIImage(named: "foodAllergyRegistImageOff1") ?? UIImage()
    case .갑각류:
      return UIImage(named: "foodAllergyRegistImageOff2") ?? UIImage()
    case .생선:
      return UIImage(named: "foodAllergyRegistImageOff3") ?? UIImage()
    case .메밀복숭아:
      return UIImage(named: "foodAllergyRegistImageOff4") ?? UIImage()
    case .견과류:
      return UIImage(named: "foodAllergyRegistImageOff5") ?? UIImage()
    case .달걀:
      return UIImage(named: "foodAllergyRegistImageOff6") ?? UIImage()
    case .우유:
      return UIImage(named: "foodAllergyRegistImageOff7") ?? UIImage()
    }
  }
}
