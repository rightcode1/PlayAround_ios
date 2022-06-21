//
//  Used+Enum.swift
//  PlayAround
//
//  Created by haon on 2022/06/15.
//

import Foundation
import UIKit

enum UsedCategory: String, Codable {
  case 전체
  case 육아
  case 골프
  case 서적
  case 가전
  case IT
  case 소형가전
  
  func onImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "usedCategoryOn1") ?? UIImage()
    case .육아:
      return UIImage(named: "usedCategoryOn2") ?? UIImage()
    case .골프:
      return UIImage(named: "usedCategoryOn3") ?? UIImage()
    case .서적:
      return UIImage(named: "usedCategoryOn4") ?? UIImage()
    case .가전:
      return UIImage(named: "usedCategoryOn5") ?? UIImage()
    case .IT:
      return UIImage(named: "usedCategoryOn6") ?? UIImage()
    case .소형가전:
      return UIImage(named: "usedCategoryOn7") ?? UIImage()
    }
  }
  
  func offImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "usedCategoryOff1") ?? UIImage()
    case .육아:
      return UIImage(named: "usedCategoryOff2") ?? UIImage()
    case .골프:
      return UIImage(named: "usedCategoryOff3") ?? UIImage()
    case .서적:
      return UIImage(named: "usedCategoryOff4") ?? UIImage()
    case .가전:
      return UIImage(named: "usedCategoryOff5") ?? UIImage()
    case .IT:
      return UIImage(named: "usedCategoryOff6") ?? UIImage()
    case .소형가전:
      return UIImage(named: "usedCategoryOff7") ?? UIImage()
    }
  }
  
  func onRegistImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "usedCategoryRegistOn1") ?? UIImage()
    case .육아:
      return UIImage(named: "usedCategoryRegistOn2") ?? UIImage()
    case .골프:
      return UIImage(named: "usedCategoryRegistOn3") ?? UIImage()
    case .서적:
      return UIImage(named: "usedCategoryRegistOn4") ?? UIImage()
    case .가전:
      return UIImage(named: "usedCategoryRegistOn5") ?? UIImage()
    case .IT:
      return UIImage(named: "usedCategoryRegistOn6") ?? UIImage()
    case .소형가전:
      return UIImage(named: "usedCategoryRegistOn7") ?? UIImage()
    }
  }
  
  func offRegistImage() -> UIImage {
    switch self {
    case .전체:
      return UIImage(named: "usedCategoryRegistOff1") ?? UIImage()
    case .육아:
      return UIImage(named: "usedCategoryRegistOff2") ?? UIImage()
    case .골프:
      return UIImage(named: "usedCategoryRegistOff3") ?? UIImage()
    case .서적:
      return UIImage(named: "usedCategoryRegistOff4") ?? UIImage()
    case .가전:
      return UIImage(named: "usedCategoryRegistOff5") ?? UIImage()
    case .IT:
      return UIImage(named: "usedCategoryRegistOff6") ?? UIImage()
    case .소형가전:
      return UIImage(named: "usedCategoryRegistOff7") ?? UIImage()
    }
  }
}
