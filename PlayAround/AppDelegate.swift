//
//  AppDelegate.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/11.
//

import UIKit
import IQKeyboardManagerSwift
import SocketIO
import KakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
    
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    KakaoSDK.initSDK(appKey: "f3787f1b7a1bf6f61a6755ee7406163a")
    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    SocketIOManager.sharedInstance.connection() 
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    SocketIOManager.sharedInstance.disConnection()
  }
  
}

