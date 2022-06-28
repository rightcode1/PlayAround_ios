//
//  AppDelegate.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/11.
//

import UIKit
import IQKeyboardManagerSwift
import SocketIO

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    SocketIOManager.sharedInstance.connection() 
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    SocketIOManager.sharedInstance.disConnection()
  }
  
}

