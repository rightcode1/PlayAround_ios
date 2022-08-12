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
  
  var userAPI = MoyaProvider<UserAPI>()
  var authAPI = MoyaProvider<AuthApi>()
  var villageAPI = MoyaProvider<VillageApi>()
  
  var communityAPI = MoyaProvider<CommunityApi>()
  
  var foodAPI = MoyaProvider<FoodApi>()
  var foodCommnetAPI = MoyaProvider<FoodCommentAPI>()
  var foodWishAPI = MoyaProvider<FoodWishAPI>()
  var foodLikeAPI = MoyaProvider<FoodLikeAPI>()
  
  var followAPI = MoyaProvider<FollowAPI>()
  
  var usedAPI = MoyaProvider<UsedAPI>()
  var reportAPI = MoyaProvider<ReportAPI>()
  
  var hashtagAPI = MoyaProvider<HashtagAPI>()
  
  var noticeAPI = MoyaProvider<NoticeAPI>()
  var faqAPI = MoyaProvider<FAQAPI>()
  var inquiryAPI = MoyaProvider<InquiryAPI>()
  var chatAPI = MoyaProvider<ChatAPI>()
  
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
    
    userAPI = MoyaProvider<UserAPI>(plugins: [MoyaLoggingPlugin()])
    authAPI = MoyaProvider<AuthApi>(plugins: [MoyaLoggingPlugin()])
    villageAPI = MoyaProvider<VillageApi>(plugins: [MoyaLoggingPlugin()])
    
    communityAPI = MoyaProvider<CommunityApi>(plugins: [MoyaLoggingPlugin()])
    
    foodAPI = MoyaProvider<FoodApi>(plugins: [MoyaLoggingPlugin()])
    foodCommnetAPI = MoyaProvider<FoodCommentAPI>(plugins: [MoyaLoggingPlugin()])
    foodWishAPI = MoyaProvider<FoodWishAPI>(plugins: [MoyaLoggingPlugin()])
    foodLikeAPI = MoyaProvider<FoodLikeAPI>(plugins: [MoyaLoggingPlugin()])
    
    followAPI = MoyaProvider<FollowAPI>(plugins: [MoyaLoggingPlugin()])
    
    usedAPI = MoyaProvider<UsedAPI>(plugins: [MoyaLoggingPlugin()])
    reportAPI = MoyaProvider<ReportAPI>(plugins: [MoyaLoggingPlugin()])
    
    hashtagAPI = MoyaProvider<HashtagAPI>(plugins: [MoyaLoggingPlugin()])
    
    noticeAPI = MoyaProvider<NoticeAPI>(plugins: [MoyaLoggingPlugin()])
    faqAPI = MoyaProvider<FAQAPI>(plugins: [MoyaLoggingPlugin()])
    inquiryAPI = MoyaProvider<InquiryAPI>(plugins: [MoyaLoggingPlugin()])
    chatAPI = MoyaProvider<ChatAPI>(plugins: [MoyaLoggingPlugin()])
  }
  
  func getErrorStatusCode(_ error: Error) -> Int {
    let moayError: MoyaError? = error as? MoyaError
    let response: Response? = moayError?.response
    let statusCode: Int? = response?.statusCode
    return statusCode ?? 499
  }
}

extension MoyaError {
  var backendError: DefaultResponse? {
    return response.flatMap {
      try? $0.map(DefaultResponse.self)
    }
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
