//
//  APIProvider.swift
//  coffit
//
//  Created by haon on 2022/04/19.
//

import Foundation
import Moya
final class APIProvider {
  static let shared = APIProvider()
  
  var userAPI = MoyaProvider<UserApi>()
  var authAPI = MoyaProvider<AuthApi>()
  var communityAPI = MoyaProvider<CommunityApi>()
  var foodAPI = MoyaProvider<FoodApi>()
  var usedAPI = MoyaProvider<UsedApi>()
  
  private init() {
//
//    let networkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(formatter: .init(entry: { (string1, string2, targetType) -> String in
//      if string1 != "Response" {
//        return "[\(string1)] \(string2)"
//      }
//      return "Response"
//    }, requestData: { data -> (String) in
//      return (data.prettyPrintedJSONString as String?) ?? ""
//    }, responseData: { data -> (String) in
//      return (data.prettyPrintedJSONString as String?) ?? ""
//    }), output: { (targetType, stringList) in
//      print("------------------------------------------------------------")
//      stringList.forEach { if $0 != "Response" { print($0) } }
//      print("------------------------------------------------------------")
//    }, logOptions: [.verbose]))
//
//    let networkActivityPlugin = NetworkActivityPlugin { (networkActivityChangeType, targetType) in
//      switch networkActivityChangeType {
//      case .began: break
//      case .ended: break
//      }
//    }
    
    userAPI = MoyaProvider<UserApi>(plugins: [MoyaLoggingPlugin()])
    authAPI = MoyaProvider<AuthApi>(plugins: [MoyaLoggingPlugin()])
    communityAPI = MoyaProvider<CommunityApi>(plugins: [MoyaLoggingPlugin()])
    foodAPI = MoyaProvider<FoodApi>(plugins: [MoyaLoggingPlugin()])
    usedAPI = MoyaProvider<UsedApi>(plugins: [MoyaLoggingPlugin()])
  }
}


extension Encodable {
  var dictionary: [String: Any]? {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = [.prettyPrinted]
    guard let data = try? jsonEncoder.encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
