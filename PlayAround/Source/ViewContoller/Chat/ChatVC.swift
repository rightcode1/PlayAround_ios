//
//  ChatVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/23.
//

import UIKit
import SocketIO
import SwiftyJSON
import IQKeyboardManagerSwift

class ChatVC: BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var isSecretView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var subNameLabel: UILabel!
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var inputTextBackView: UIView!
  @IBOutlet weak var inputTextView: UITextView! {
    didSet{
      inputTextView.font = .systemFont(ofSize: 14)
      inputTextView.delegate = self
    }
  }
  @IBOutlet weak var inputTextViewPlaceHolder: UILabel!
  @IBOutlet weak var inputTextBottomConst: NSLayoutConstraint!
  
  @IBOutlet weak var registButton: UIButton!
  
  var chatRoomData: ChatRoomData?
  
  let socketManager = SocketIOManager.sharedInstance
  
  var chatRoomId: Int = -1
  var isMaster: Bool = false
  var messageList: [MessageData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setNotificationCenter()
    setTableView()
    socketOn()
    bindInput()
    setTopViewInfo()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    IQKeyboardManager.shared.enableAutoToolbar = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    scrollToBottom()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    IQKeyboardManager.shared.enableAutoToolbar = true
  }
  
  static func viewController() -> ChatVC {
    let viewController = ChatVC.viewController(storyBoardName: "Chat")
    return viewController
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
    self.tableView.endEditing(true)
  }
  
  func setTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  func setNotificationCenter() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  // 텍스트의 맞게 텍스트뷰 높이 설정
  func setTextViewHeight() {
    let size = CGSize(width: inputTextView.frame.width, height: .infinity)
    let estimatedSize = inputTextView.sizeThatFits(size)
    inputTextView.constraints.forEach { (constraint) in
      if constraint.firstAttribute == .height {
        constraint.constant = estimatedSize.height
      }
    }
  }
  
  @objc func keyboardWillShow(_ notification: NSNotification) {
    if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveEaseOut, animations: {
        print("\(APP_WIDTH())/\(APP_HEIGHT())")
        
        if APP_WIDTH() >= 375 && APP_HEIGHT() > 750 {
          self.inputTextBottomConst.constant = keyboardRect.height - 34
        } else {
          self.inputTextBottomConst.constant = keyboardRect.height
        }
        self.view.layoutIfNeeded()
      })
    }
  }
  
  @objc func keyboardWillHide(_ notification: NSNotification) {
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      self.inputTextBottomConst.constant = 0
      self.view.layoutIfNeeded()
    })
  }
  
  // 스크롤 맨 아래로
  func scrollToBottom() {
    let index = IndexPath(row: self.messageList.count - 1, section: 0)
    self.tableView.scrollToRow(at: index, at: UITableView.ScrollPosition.bottom, animated: true)
  }
  
  func setTopViewInfo() {
    if let chatRoomData = chatRoomData {
      updateRoomData(chatRoomData)
    }
  }
  
  func updateRoomData(_ data: ChatRoomData) {
    if data.thumbnail != nil && !(data.thumbnail ?? "default").contains(find: "default") {
      thumbnailImageView.kf.setImage(with: URL(string: data.thumbnail!))
    } else {
      thumbnailImageView.image = UIImage(named: "defaultBoardImage")
    }
    
    isSecretView.isHidden = (data.isSecret ?? 0) == 0
    navigationItem.title = data.name
    nameLabel.text = data.name
    subNameLabel.text = data.from
  }
  
  func socketOn() {
    socketManager.enterRoom(chatRoomId: chatRoomId) { (isMaster: Bool, messageList: [MessageData]) in
      self.isMaster = isMaster
      self.messageList = messageList
      self.tableView.reloadData()
    }
    
    socketManager.messageRefresh { messageData in
      self.messageList.append(messageData)
      self.tableView.reloadData()
    }
  }
  
  func finishSendMessageEvent() {
    inputTextView.text = nil
    inputTextView.heightAnchor.constraint(equalToConstant: 35).isActive = true
    inputTextBottomConst.constant = 0
    scrollToBottom()
    self.view.endEditing(true)
  }
  
  func bindInput() {
    registButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if !self.inputTextView.text.isEmpty {
          self.socketManager.sendMessage(chatRoomId: self.chatRoomId, message: self.inputTextView.text!)
          self.finishSendMessageEvent()
        }
      })
      .disposed(by: disposeBag)
    
    inputTextView.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        self?.inputTextViewPlaceHolder.isHidden = !text.isEmpty
      })
      .disposed(by: disposeBag)
  }
  
  @IBAction func tapBack(_ sender: UIBarButtonItem) {
    socketManager.checkOutRoom()
    backPress()
  }
}

extension ChatVC: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let spacing = CharacterSet.whitespacesAndNewlines
    if !textView.text.trimmingCharacters(in: spacing).isEmpty || !textView.text.isEmpty {
      textView.textColor = .black
    } else if textView.text.isEmpty {
      textView.textColor = .lightGray
    }
    setTextViewHeight()
  }
}

extension ChatVC: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messageList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
    
    let messageData = messageList[indexPath.row]
    
    let beforeData = messageList.indices.contains(indexPath.item - 1) ? messageList[indexPath.item - 1] : nil
    let nextData = messageList.indices.contains(indexPath.item + 1) ? messageList[indexPath.item + 1] : nil
    
    cell.setHeaderDate(beforeData: beforeData, currentData: messageData, nextData: nextData)
    
    cell.update(messageData, myId: DataHelperTool.userAppId ?? 0)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 150
  }
}
