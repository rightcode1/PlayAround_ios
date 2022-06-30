//
//  ChatRoomLIstVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/23.
//

import UIKit
import SocketIO
import SwiftyJSON

enum ChatRoomType: String, Codable {
  case 커뮤니티
  case 반찬공유
  case 중고거래
}

class ChatRoomListVC: UIViewController {
  @IBOutlet weak var typeCollectionView: UICollectionView!
  @IBOutlet weak var tableView: UITableView!
  
  let socketManager = SocketIOManager.sharedInstance
  
  var typeList: [ChatRoomType] = [.커뮤니티, .반찬공유, .중고거래]
  var selectedType: ChatRoomType = .커뮤니티
  
  var chatRoomList: [ChatRoomData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setTableView()
    setCollectionView()
    
    initChatRoomList()
    socketOn()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
  }
  
  func setCollectionView() {
    typeCollectionView.delegate = self
    typeCollectionView.dataSource = self
  }
  
  func setTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  func initChatRoomList() {
    socketManager.getRoomList(type: selectedType.rawValue) { list in
      self.chatRoomList.removeAll()
      if list.count > 0 {
        for data in list {
          self.chatRoomList.append(ChatRoomData(dict: data))
        }
      }
      self.tableView.reloadData()
    }
  }
  
  func socketOn() {
    socketManager.roomListUpdate { list in
      self.chatRoomList.removeAll()
      if list.count > 0 {
        for data in list {
          self.chatRoomList.append(ChatRoomData(dict: data))
        }
      }
      self.tableView.reloadData()
    }
  }
  
  func sendMessage(_ message: String) {
    
  }
  
}

extension ChatRoomListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return typeList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = typeCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    
    let dict = typeList[indexPath.row]
    
    let selectedTextColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
    let defaultTextColor = UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0)
    
    (cell.viewWithTag(1) as! UILabel).text = dict.rawValue
    (cell.viewWithTag(1) as! UILabel).textColor = dict != selectedType ? defaultTextColor : selectedTextColor
    
    (cell.viewWithTag(2)!).isHidden = dict != selectedType
    
    return cell
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let dict = typeList[indexPath.row]
    
    selectedType = dict
    typeCollectionView.reloadData()
    initChatRoomList()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let dict = typeList[indexPath.row]
    let width = textWidth(text: dict.rawValue, font: .systemFont(ofSize: 12, weight: .medium)) + 18
    
    return CGSize(width: width, height: 30)
  }
}

extension ChatRoomListVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatRoomList.count == 0 ? 1 : chatRoomList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if chatRoomList.count == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "noneCell")!
      cell.selectionStyle = .none
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomListCell") as! ChatRoomListCell
      let data = chatRoomList[indexPath.row]
      
      cell.update(data)
      
      cell.selectionStyle = .none
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return chatRoomList.count == 0 ? APP_HEIGHT() - 264 : 88
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if chatRoomList.count != 0 {
      let dict = chatRoomList[indexPath.row]
      let vc = ChatVC.viewController()
      vc.communityId = dict.communityId
      vc.foodId = dict.foodId
      vc.usedId = dict.usedId
      vc.chatRoomId = dict.id ?? -1
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}
