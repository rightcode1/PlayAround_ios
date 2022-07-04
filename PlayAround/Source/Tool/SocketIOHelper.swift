//
//  SocketIOHelper.swift
//  locallage
//
//  Created by hoonKim on 2020/08/20.
//  Copyright © 2020 DongSeok. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
  static let sharedInstance = SocketIOManager()
  
  let manager = SocketManager(socketURL: URL(string: "http://3.38.232.67:6070")!, config: [.log(true), .path("/socket.io"), .compress, .reconnects(true), .forceWebsockets(true)])
  
  var isConnected: Bool = false
  
  override init() {
    super.init()
    manager.defaultSocket.on(clientEvent: .connect) { data, ack in
      print("socket data : \(data)")
      print("socket ack : \(ack)")
      print("----socket connected----")
      self.manager.defaultSocket.emit("login", ["token": DataHelperTool.chatToken ?? ""])
    }
  }
  
  func connection() {
    manager.defaultSocket.connect()
    isConnected = true
  }
  
  func disConnection() {
    manager.defaultSocket.disconnect()
    isConnected = false
  }
  
  func getRoomList(type: String, result: @escaping ([[String: Any]]) -> Void) {
    manager.defaultSocket.emitWithAck("getList", ["type": type]).timingOut(after: 0) { data in
      guard let listData = data[0] as? [String: Any] else { return }
      let list = listData["list"] as? [[String: Any]]
      
      result(list ?? [])
    }
  }
  
  func roomListUpdate(result: @escaping ([[String: Any]]) -> Void) {
    manager.defaultSocket.on("listUpdate") { data, ack  in
      guard let listData = data[0] as? [String: Any] else { return }
      let list = listData["data"] as? [[String: Any]]
      
      result(list ?? [])
    }
  }
  
  func enterRoom(chatRoomId: Int, result: @escaping ((isMaster: Bool, messageList: [MessageData])) -> Void) {
    manager.defaultSocket.emitWithAck("enterRoom", ["chatRoomId": "\(chatRoomId)"]).timingOut(after: 0) { data in
      guard let responseData = data[0] as? [String: Any] else { return }
      let isMaster = responseData["isMaster"] as? Bool
      let list = responseData["data"] as? [[String: Any]]
      
      var messageList: [MessageData] = []
      
      if (list ?? []).count > 0 {
        for data in list! {
          messageList.append(MessageData(dict: data))
        }
      }
      
      result((isMaster ?? false, messageList))
    }
  }
  
  func outRoom(chatRoomId: Int, result: @escaping (Bool) -> Void) {
    manager.defaultSocket.emitWithAck("outRoom", ["chatRoomId": "\(chatRoomId)"]).timingOut(after: 0) { data in
      guard let responseData = data[0] as? [String: Any] else { return }
      let success = responseData["result"] as? Bool
      
      result(success ?? false)
    }
  }
  
  func messageRefresh(result: @escaping (MessageData) -> Void) {
    manager.defaultSocket.on("messageRefresh") { data, ack  in
      guard let messageData = data[0] as? [String: Any] else { return }
      print("messageData: \(messageData)")
      result(MessageData(dict: messageData))
    }
  }
  
  func sendMessage(chatRoomId: Int, message: String) {
    manager.defaultSocket.emit("sendMessage", ["chatRoomId": "\(chatRoomId)", "message": message])
  }
  
  func sendImage(chatRoomId: Int, messageId: Int) {
    manager.defaultSocket.emit("sendMessage", ["chatRoomId": "\(chatRoomId)", "messageId": "\(messageId)"])
  }
  
  func checkOutRoom() {
    manager.defaultSocket.emit("checkout")
  }
  
}
