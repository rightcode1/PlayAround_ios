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
import Photos
import DKImagePickerController

enum ChatDialogType: String, Codable {
  case out
  case expulsion
  case cancel
}

class ChatVC: BaseViewController, ViewControllerFromStoryboard, UIViewControllerTransitioningDelegate, DialogPopupViewDelegate {
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
  
  @IBOutlet weak var addFileButton: UIImageView!
  @IBOutlet weak var registButton: UIButton!
  
  @IBOutlet weak var outRoomButton: UIBarButtonItem!
  
  let pickerController = DKImagePickerController()
  var assets: [DKAsset]?
  var exportManually = false
  
  let socketManager = SocketIOManager.sharedInstance
  
  var communityId: Int?
  var foodId: Int?
  var usedId: Int?
  
  var chatRoomId: Int = -1
  var isMaster: Bool = false
  var messageList: [MessageData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setTopViewInfo()
    setNotificationCenter()
    setPickerController()
    setTableView()
    socketOn()
    bindInput()
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
    if self.messageList.count > 0 {
      let index = IndexPath(row: self.messageList.count - 1, section: 0)
      self.tableView.scrollToRow(at: index, at: UITableView.ScrollPosition.bottom, animated: true)
    }
  }
  
  func setTopViewInfo() {
    if let communityId = communityId {
      print("communityId: \(communityId)")
    }
    
    if let foodId = foodId {
      initFoodDetail(foodId)
    }
    
    if let usedId = usedId {
      initUsedDetail(usedId)
    }
  }
  
  func initFoodDetail(_ id: Int) {
    APIProvider.shared.foodAPI.rx.request(.foodDetail(id: id))
      .filterSuccessfulStatusCodes()
      .map(FoodDetailResponse.self)
      .subscribe(onSuccess: { value in
        guard let data = value.data else { return }
        
        if data.images.count > 0 {
          self.thumbnailImageView.kf.setImage(with: URL(string: data.images[0].name))
        } else {
          self.thumbnailImageView.image = UIImage(named: "defaultProfileImage")
        }
        
        self.navigationItem.title = data.user.name
        self.nameLabel.text = data.name
        self.subNameLabel.text = "\(data.price.formattedProductPrice() ?? "0")원"
        self.topView.isHidden = false
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initUsedDetail(_ id: Int) {
    APIProvider.shared.usedAPI.rx.request(.detail(id: id))
      .filterSuccessfulStatusCodes()
      .map(UsedDetailResponse.self)
      .subscribe(onSuccess: { value in
        guard let data = value.data else { return }
        
        if data.images.count > 0 {
          self.thumbnailImageView.kf.setImage(with: URL(string: data.images[0].name))
        } else {
          self.thumbnailImageView.image = UIImage(named: "defaultProfileImage")
        }
        
        self.navigationItem.title = data.user.name
        self.nameLabel.text = data.name
        self.subNameLabel.text = "\(data.price.formattedProductPrice() ?? "0")원"
        self.topView.isHidden = false
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func uploadMessageFile(image: UIImage) {
    APIProvider.shared.chatAPI.rx.request(.chatMessageFileRegister(chatRoomId: chatRoomId, image: image))
      .filterSuccessfulStatusCodes()
      .map(RegistChatMessageImageResponse.self)
      .subscribe(onSuccess: { response in
        
        self.socketManager.sendImage(chatRoomId: self.chatRoomId, messageId: response.data.id)
      }, onError: { error in
      })
      .disposed(by: disposeBag)
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
  
  @objc func showDialogPopupView() {
    let vc = DialogPopupView()
    vc.modalPresentationStyle = .custom
    vc.transitioningDelegate = self
    vc.delegate = self
    vc.titleString = "채팅방 나가기"
    vc.contentString = "채팅방을 나가시면 대화목록이 삭제됩니다."
    vc.okbuttonTitle = "확인"
    self.present(vc, animated: true, completion: nil)
  }
  // DialogPopupViewDelegate
  func dialogOkEvent() {
    showDialogPopupView()
  }
  
  func bindInput() {
    addFileButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.showImagePicker()
      })
      .disposed(by: disposeBag)
    
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
    
    outRoomButton.rx.tap
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        
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
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.layoutMargins = .zero
    cell.separatorInset = .zero
    cell.selectionStyle = .none
    cell.preservesSuperviewLayoutMargins = false
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

extension ChatVC {
  func setPickerController() {
    pickerController.assetType = .allPhotos
    pickerController.maxSelectableCount = 1
  }
  
  func showImagePicker() {
    if self.exportManually {
      DKImageAssetExporter.sharedInstance.add(observer: self)
    }
    
    if let assets = self.assets {
      pickerController.select(assets: assets)
    }
    
    pickerController.exportStatusChanged = { status in
      switch status {
        case .exporting:
          print("exporting")
        case .none:
          print("none")
      }
    }
    
    pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
      self.updateAssets(assets: assets)
    }
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      pickerController.modalPresentationStyle = .formSheet
    }
    
    if pickerController.UIDelegate == nil {
      pickerController.UIDelegate = AssetClickHandler()
    }
    
    pickerController.navigationBar.backgroundColor = .white
    self.present(pickerController, animated: true) {}
  }
  
  func updateAssets(assets: [DKAsset]) {
    print("didSelectAssets")
    
    self.assets = assets
    
    if pickerController.exportsWhenCompleted {
      for asset in assets {
        if let error = asset.error {
          print("exporterDidEndExporting with error:\(error.localizedDescription)")
        } else {
          print("exporterDidEndExporting:\(asset.localTemporaryPath!)")
        }
      }
    }
    
    if (self.assets?.count ?? 0) > 0 {
      DispatchQueue.global().sync {
        for asset in assets {
          asset.fetchOriginalImage { (image, nil) in
            if let image = image {
              self.uploadMessageFile(image: image)
            }
          }
        }
      }
    }
    
    if self.exportManually {
      DKImageAssetExporter.sharedInstance.exportAssetsAsynchronously(assets: assets, completion: nil)
    }
  }
}
