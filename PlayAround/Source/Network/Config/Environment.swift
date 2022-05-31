//
//  Environment.swift
//  InsideROO
//
//  Created by jason on 02/02/2019.
//  Copyright © 2019 Dong Seok Lee. All rights reserved.
//

import Foundation
import UIKit

var FcmToken: String = ""

var currentLocation: (Double, Double)?

let defaultAddress: UserAddress = UserAddress(nickname: "기본", addressName: "충청북도 청주시 상당구 북문로3가 89-1", roadAddressName: "충청북도 청주시 상당구 북문로3가 상당로 155", addressDetail: "충청북도 청주시 상당구 북문로3가 89-1", longitude: "127.3916172", latitude: "36.6519575")

struct ApiEnvironment {
    static let baseUrl = "http://3.38.232.67:6070"
    static let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as! String
    static let kakaoRESTKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_REST_KEY") as! String
    //  static let serverGatewayStage = Bundle.main.object(forInfoDictionaryKey: "SERVER_GATEWAY_STAGE") as! String
}

public struct UserAddress: Codable {
  let nickname: String
  let addressName: String
  let roadAddressName: String
  let addressDetail: String
  let longitude: String
  let latitude: String
}
