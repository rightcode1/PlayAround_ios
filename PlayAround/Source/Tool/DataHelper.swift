//
//  DataHelper.swift
//  OPenPal
//
//  Created by jason on 11/10/2018.
//  Copyright © 2018 WePlanet. All rights reserved.
//

import Foundation
//import FirebaseMessaging

class DataHelper<T> {
  
  enum DataKeys: String {
    case userId = "userId"
    case userPw = "userPw"
    case token = "token"
  }
  
  class func value(forKey key: DataKeys) -> T? {
    if let data = UserDefaults.standard.value(forKey: key.rawValue) as? T {
      return data
    }else {
      return nil
    }
  }
  
  
  class func set(_ value:T, forKey key: DataKeys){
    UserDefaults.standard.set(value, forKey : key.rawValue)
  }
  
  class func remove(forKey key: DataKeys) {
    UserDefaults.standard.removeObject(forKey: key.rawValue)
  }
  
  class func clearAll(){
    UserDefaults.standard.dictionaryRepresentation().keys.forEach{ key in
      UserDefaults.standard.removeObject(forKey: key.description)
    }
  }
}

class DataHelperTool {
  
  static var userId: String? {
    guard let userId = DataHelper<String>.value(forKey: .userId) else { return nil }
    return userId
  }
  
  static var userPw: String? {
    guard let userPw = DataHelper<String>.value(forKey: .userPw) else { return nil }
    return userPw
  }
  
  static var token: String? {
    guard let token = DataHelper<String>.value(forKey: .token) else { return nil }
    return token
  }
}
  
