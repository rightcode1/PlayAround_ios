//
//  UsedDetailVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/15.
//

import UIKit
import RxSwift
import IQKeyboardManagerSwift
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

class UsedDetailVC: BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var wishBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  
  @IBOutlet weak var hashTagCollectionView: UICollectionView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var thumbnailCollectionView: UICollectionView!
  @IBOutlet weak var thumbnailCountLabel: UILabel!
  
  @IBOutlet weak var foodStatusStackView: UIStackView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  @IBOutlet weak var userThumbnailImageView: UIImageView!
  @IBOutlet weak var userUsedLevelImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var wishCountLabel: UILabel!
  @IBOutlet weak var viewCountLabel: UILabel!
  @IBOutlet weak var checkCheatButton: UIButton!
  @IBOutlet weak var followButton: UIButton!
  
  @IBOutlet weak var likeButton: UIImageView!
  @IBOutlet weak var dislikeButton: UIImageView!
  @IBOutlet weak var likeCountLabel: UILabel!
  @IBOutlet weak var disLikeCountLabel: UILabel!
    @IBOutlet weak var soldOutView: UIView!
    
  @IBOutlet weak var usedContentLabel: UILabel!
  
  @IBOutlet weak var userNameLabel2: UILabel!
  @IBOutlet weak var anotherUsedView: UIStackView!
  @IBOutlet weak var anotherUsedListCollectionView: UICollectionView!
  
  @IBOutlet weak var commentCountlabel: UILabel!
  @IBOutlet weak var registCommentButton: UIButton!
  
  @IBOutlet weak var replyView: UIView!
  @IBOutlet weak var replyLabel: UILabel!
  @IBOutlet weak var cancelReplyButton: UIButton!
  
  @IBOutlet weak var inputCommentView: UIView!
  @IBOutlet weak var inputTextView: UITextView! {
    didSet {
      inputTextView.delegate = self
    }
  }
  @IBOutlet weak var inputTextViewPlaceHolder: UILabel!
  @IBOutlet weak var inputTextBottomConst: NSLayoutConstraint!
  @IBOutlet weak var bottomConst: NSLayoutConstraint!
  
  @IBOutlet weak var registCommentButton2: UIButton!
  
  @IBOutlet weak var chatButton: UIButton!
  var hashTagList: [String] = []
  
  var usedId: Int = -1
  
  var isMine: Bool = false
  
  var thumbnailList: [Image] = []
  var thumbnailUIImageList: [UIImage] = []
  
  var usedUserId: Int = -1
  let isFollow = BehaviorSubject<Bool>(value: false)
  
  var isEndRequest = false
  var isFullRequest = false
  var isRequest = false
  
  let isWish = BehaviorSubject<Bool>(value: false)
    
    var status: Bool?
    var detaildata : UsedDetailData?
  var anotherUsedList: [UsedListData] = []
  
  var replyCommentId: Int?
  var commentList: [UsedCommentListData] = []
  
  var chatRoomHeaderData: ChatRoomHeaderData?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    IQKeyboardManager.shared.enableAutoToolbar = false
    setTableView()
    setCollectionView()
    bindInput()
    bindOutput()
    registNotificationCenter()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    initUserInfo()
    setTextViewHeight()
  }
  
  override func viewDidLayoutSubviews() {
    tableView.layoutTableHeaderView()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    IQKeyboardManager.shared.enableAutoToolbar = true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
    self.view.endEditing(true)
    self.tableView.endEditing(true)
  }
  
  static func viewController() -> UsedDetailVC {
    let viewController = UsedDetailVC.viewController(storyBoardName: "Used")
    return viewController
  }
  
  func registNotificationCenter() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  func resetReplyInfo() {
    self.replyCommentId = nil
    self.replyView.alpha = 0
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
          self.bottomConst.constant = keyboardRect.height - 34
        } else {
          self.inputTextBottomConst.constant = keyboardRect.height
          self.bottomConst.constant = keyboardRect.height
        }
        
        self.inputCommentView.isHidden = false
        self.chatButton.isHidden = true
        self.view.layoutIfNeeded()
      })
    }
  }
  
  @objc func keyboardWillHide(_ notification: NSNotification) {
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      self.resetReplyInfo()
      self.inputTextBottomConst.constant = 0
      self.bottomConst.constant = 0
      self.inputCommentView.isHidden = true
      self.chatButton.isHidden = false
      self.view.layoutIfNeeded()
    })
  }
  
  func setTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  func setCollectionView() {
    thumbnailCollectionView.delegate = self
    thumbnailCollectionView.dataSource = self
    
    anotherUsedListCollectionView.delegate = self
    anotherUsedListCollectionView.dataSource = self
    
    setThumbnailCollectionViewLayout()
    setAnotherFoodListCollectionViewLayout()
  }
  
  func setThumbnailCollectionViewLayout() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.itemSize = CGSize(width: APP_WIDTH(), height: 260)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.invalidateLayout()
    layout.scrollDirection = .horizontal
    thumbnailCollectionView.collectionViewLayout = layout
  }
  
  func setAnotherFoodListCollectionViewLayout() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    layout.itemSize = CGSize(width: (APP_WIDTH() - 60) / 2, height: 170)
    layout.minimumInteritemSpacing = 10
    layout.minimumLineSpacing = 10
    layout.invalidateLayout()
    anotherUsedListCollectionView.collectionViewLayout = layout
  }
  
  func initFollowButton(_ isFollow: Bool) {
    followButton.backgroundColor = isFollow ? .white : UIColor(red: 243/255, green: 112/255, blue: 34/255, alpha: 1.0)
    followButton.layer.borderWidth = isFollow ? 1 : 0
    followButton.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0).cgColor
    followButton.setTitleColor(isFollow ? UIColor(red: 188/255, green: 188/255, blue: 188/255, alpha: 1.0) : .white, for: .normal)
    followButton.setTitle(isFollow ? "팔로잉" : "+팔로우", for: .normal)
  }
  
  func initUserInfo() {
    userInfo() { result in
      self.initUsedDetail()
      self.initAnotherFoodList(userId: result.data.id)
    }
  }
  
  func initUsedDetail() {
    self.showHUD()
    APIProvider.shared.usedAPI.rx.request(.detail(id: usedId))
      .filterSuccessfulStatusCodes()
      .map(UsedDetailResponse.self)
      .subscribe(onSuccess: { value in
        guard let data = value.data else { return }
          self.detaildata = value.data
        self.navigationItem.title = data.category.rawValue
        
        self.thumbnailList = data.images
        DispatchQueue.main.async {
          self.thumbnailUIImageList = self.initUIImageList(data.images)
        }
        self.thumbnailCountLabel.text = "1/\(self.thumbnailList.count)"
        self.thumbnailCollectionView.reloadData()
        
        self.foodStatusStackView.arrangedSubviews[0].isHidden = true
        self.foodStatusStackView.arrangedSubviews[1].isHidden = true
        
        self.isWish.onNext(data.isWish)
        self.titleLabel.text = data.name
        self.priceLabel.text = "\(data.price.formattedProductPrice() ?? "0")원"
          self.soldOutView.isHidden = !data.statusSale
          if data.statusSale{
              self.chatButton.backgroundColor = .systemGray3
              self.chatButton.setTitle("판매완료", for: .normal)
          }
        
        let userData = data.user
        self.usedUserId = userData.id
        if userData.thumbnail != nil {
          self.userThumbnailImageView.kf.setImage(with: URL(string: userData.thumbnail ?? ""))
        } else {
          self.userThumbnailImageView.image = UIImage(named: "defaultBoardImage")
        }
        self.userUsedLevelImageView.image = self.usedLevelImage(level: userData.usedLevel ?? 1)
        self.userNameLabel.text = userData.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let createdAtDate = dateFormatter.date(from: data.createdAt) {
          self.dateLabel.text = createdAtDate.toString(dateFormat: "yyyy-MM-dd HH:mm")
        } else {
          self.dateLabel.text = data.createdAt
        }
      
        self.wishCountLabel.text = "\(data.wishCount)"
        self.viewCountLabel.text = "조회 \(data.viewCount)"
        self.isFollow.onNext(userData.isFollowing)
        
        self.isMine = data.userId == DataHelperTool.userAppId ?? 0
        self.userNameLabel2.text = userData.name

        self.usedContentLabel.text = data.content
        self.hashTagList = data.hashtag.map({ "#\($0)" })
        self.hashTagCollectionView.reloadData()
        
        self.status = data.isLike
          self.likeButtonState(state: self.status)
          self.likeCountLabel.text = "\(data.likeCount)"
          self.disLikeCountLabel.text = "\(data.dislikeCount)"
        
        self.initCommentList()
        
        let chatRoomHeaderData = ChatRoomHeaderData(thumbnail: data.images.count > 0 ? data.images[0].name : nil, name: data.user.name, title: data.name)
        self.chatRoomHeaderData = chatRoomHeaderData
        
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initAnotherFoodList(userId: Int) {
    let param = UsedListRequest(userId: userId)
    APIProvider.shared.usedAPI.rx.request(.list(param: param))
      .filterSuccessfulStatusCodes()
      .map(UsedListResponse.self)
      .subscribe(onSuccess: { value in
        self.anotherUsedList = value.list
        self.anotherUsedView.isHidden = value.list.count <= 0
        self.anotherUsedListCollectionView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initCommentList() {
    APIProvider.shared.usedAPI.rx.request(.commentList(usedId: usedId))
      .filterSuccessfulStatusCodes()
      .map(UsedCommentListResponse.self)
      .subscribe(onSuccess: { value in
        self.commentList = value.list
        self.commentCountlabel.text = "\(value.list.count)"
        self.tableView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func registWish() {
    let param = RegistUsedWishRequest(usedId: usedId)
    APIProvider.shared.usedAPI.rx.request(.wishRegister(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.initUsedDetail()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func removeWish() {
    APIProvider.shared.usedAPI.rx.request(.wishRemove(usedId: usedId))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.initUsedDetail()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func registLike(isLike: Bool) {
    let param = RegistUsedLikeRequest(isLike: isLike, usedId: usedId)
    APIProvider.shared.usedAPI.rx.request(.likeRegister(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
          self.status = isLike
          if self.status == true{
              self.likeCountLabel.text = "\((Int(self.likeCountLabel.text ?? "0") ?? 0) + 1)"
          }else if self.status == false{
              self.disLikeCountLabel.text = "\((Int(self.disLikeCountLabel.text ?? "0") ?? 0) + 1)"
          }else{
              
          }
          self.likeButtonState(state: isLike)
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func removeLike() {
    APIProvider.shared.usedAPI.rx.request(.likeRemove(id: usedId))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
          if self.status == true{
              self.likeCountLabel.text = "\((Int(self.likeCountLabel.text ?? "0") ?? 0) - 1)"
          }else if self.status == false{
              self.disLikeCountLabel.text = "\((Int(self.disLikeCountLabel.text ?? "0") ?? 0) - 1)"
          }else{
              
          }
          self.status = nil
          self.likeButtonState(state: nil)
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
    func removeAndRegistLike(isLike: Bool) {
        APIProvider.shared.usedAPI.rx.request(.likeRemove(id: usedId))
            .filterSuccessfulStatusCodes()
            .map(DefaultResponse.self)
            .subscribe(onSuccess: { value in
                let param = RegistUsedLikeRequest(isLike: isLike, usedId: self.usedId)
                APIProvider.shared.usedAPI.rx.request(.likeRegister(param: param))
                    .filterSuccessfulStatusCodes()
                    .map(DefaultResponse.self)
                    .subscribe(onSuccess: { value in
                        self.status = isLike
                        if self.status == true{
                            self.likeCountLabel.text = "\((Int(self.likeCountLabel.text ?? "0") ?? 0) + 1)"
                            self.disLikeCountLabel.text = "\((Int(self.disLikeCountLabel.text ?? "0") ?? 0) - 1)"
                        }else{
                            self.disLikeCountLabel.text = "\((Int(self.disLikeCountLabel.text ?? "0") ?? 0) + 1)"
                            self.likeCountLabel.text = "\((Int(self.likeCountLabel.text ?? "0") ?? 0) - 1)"
                        }
                        self.likeButtonState(state: isLike)
                    }, onError: { error in
                    })
                    .disposed(by: self.disposeBag)
            }, onError: { error in
            })
            .disposed(by: disposeBag)
    }
    func likeButtonState(state: Bool?){
        if state == nil{
            self.likeButton.image = UIImage(named: "likeoff")
            self.dislikeButton.image = UIImage(named: "dislikeoff")
            
        }else if state == true{
            self.dislikeButton.image = UIImage(named: "dislikeoff")
            self.likeButton.image = UIImage(named: "like")
        }else if state == false{
            self.likeButton.image = UIImage(named: "likeoff")
            self.dislikeButton.image = UIImage(named: "dislike")
        }
        
    }
  
  func registFollow() {
    let param = RegistFollowRequest(userId: usedUserId)
    APIProvider.shared.followAPI.rx.request(.register(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.isFollow.onNext(true)
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func removeFollow() {
    APIProvider.shared.followAPI.rx.request(.remove(userId: usedUserId))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.isFollow.onNext(false)
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func registComment() {
    let param = RegistUsedCommentRequest(usedId: usedId, content: inputTextView.text!, usedCommentId: replyCommentId)
    APIProvider.shared.usedAPI.rx.request(.commentRegister(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.resetReplyInfo()
        self.inputTextView.text = nil
        self.view.endEditing(true)
        self.initCommentList()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func startChat() {
    let param = RegistChatRoomRequest(usedId: usedId, userId: usedUserId)
    APIProvider.shared.chatAPI.rx.request(.roomRegister(param: param))
      .filterSuccessfulStatusCodes()
      .map(RegistChatRoomResponse.self)
      .subscribe(onSuccess: { value in
        let vc = ChatVC.viewController()
        vc.usedId = self.usedId
        vc.chatRoomId = value.data.id
        self.navigationController?.pushViewController(vc, animated: true)
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func bindInput() {
    wishBarButtonItem.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        print("self.isWish: \(try! self.isWish.value())")
        
        if try! self.isWish.value() {
          self.removeWish()
        } else {
          self.registWish()
        }
      })
      .disposed(by: disposeBag)
    
    menuBarButtonItem.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = FoodDetailMenuPopupVC.viewController()
        vc.isMine.onNext(self.isMine)
        vc.delegate = self
        self.present(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    followButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if try! self.isFollow.value() {
          self.removeFollow()
        } else {
          self.registFollow()
        }
      })
      .disposed(by: disposeBag)
    
    checkCheatButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = CheckCrimeHistoryPopupVC.viewController()
        vc.delegate = self
        self.present(vc, animated: true)
      })
      .disposed(by: disposeBag)
      likeButton.rx.tapGesture().when(.recognized)
          .bind(onNext: { [weak self] _ in
              guard let self = self else { return }
              
              if self.status == nil{
                  self.registLike(isLike: true)
              }else if self.status == false{
                  self.removeAndRegistLike(isLike: true)
              }else{
                  self.removeLike()
              }
              
          }).disposed(by: disposeBag)
      
      dislikeButton.rx.tapGesture().when(.recognized)
          .bind(onNext: { [weak self] _ in
              guard let self = self else { return }
              if self.status == nil{
                  self.registLike(isLike: false)
              }else if self.status == true{
                  self.removeAndRegistLike(isLike: false)
              }else{
                  self.removeLike()
              }
              
          }).disposed(by: disposeBag)
    
    cancelReplyButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.resetReplyInfo()
      })
      .disposed(by: disposeBag)
    
    registCommentButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.inputTextView.becomeFirstResponder()
      })
      .disposed(by: disposeBag)
    
    registCommentButton2.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if !self.inputTextView.text.isEmpty {
          self.registComment()
        }
      })
      .disposed(by: disposeBag)
    
    inputTextView.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        self?.inputTextViewPlaceHolder.isHidden = !text.isEmpty
      })
      .disposed(by: disposeBag)
    
    chatButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
          if self.chatButton.currentTitle != "판매완료"{
              self.startChat()
          }
      })
      .disposed(by: disposeBag)
  }
  
  func bindOutput() {
//    isLike
//      .bind(onNext: { [weak self] isLike in
//        guard let self = self else { return }
//        if let bool = isLike {
//
//        } else {
//          self.likeButton.image = UIImage(named: "likeoff")
//          self.dislikeButton.image = UIImage(named: "dislikeoff")
//        }
//      })
//      .disposed(by: disposeBag)
    
    isWish
      .bind(onNext: { [weak self] isWish in
        guard let self = self else { return }
        if isWish {
          self.wishBarButtonItem.image = UIImage(named: "heartFull")
        } else {
          self.wishBarButtonItem.image = UIImage(named: "heardEmpty")
        }
      })
      .disposed(by: disposeBag)
    
    isFollow
      .bind(onNext: { [weak self] isFollow in
        guard let self = self else { return }
        self.initFollowButton(isFollow)
      })
      .disposed(by: disposeBag)
    
//    likeCount
//      .bind(onNext: { [weak self] count in
//        guard let self = self else { return }
//        self.likeCountLabel.text = "\(count)"
//      }).disposed(by: disposeBag)
//
//    dislikeCount
//      .bind(onNext: { [weak self] count in
//        guard let self = self else { return }
//        self.disLikeCountLabel.text = "\(count)"
//      }).disposed(by: disposeBag)
  }
  
}

extension UsedDetailVC: UITextViewDelegate {
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

extension UsedDetailVC: FoodCommentListCellDelegate {
  func setReplyInfo(commentId: Int, userName: String) {
    self.inputTextView.becomeFirstResponder()
    replyCommentId = commentId
    replyLabel.text = "\(userName)님에게 답글 다는 중..."
    UIView.animate(withDuration: 0.5) {
      self.replyView.alpha = 1.0
      self.replyView.layoutIfNeeded()
    }
  }
}

extension UsedDetailVC: CheckCrimeHistoryDelegate {
  func moveToCheckCheatWithWeb(urlString: String) {
    openUrl(urlString)
  }
}

extension UsedDetailVC: FoodDetailMenuDelegate {
  func shareFood() {
      var image = ""
      if detaildata?.images.count != 0{
          image = detaildata?.images[0].name ?? ""
      }
            let feedTemplateJsonStringData =
            """
            {
              "object_type": "feed",
              "content": {
                "title": "\(detaildata?.name ?? "")",
                "description": "\(detaildata?.hashtag.map({ "#\($0)" }).joined(separator: " ") ?? "")",
                "image_url": "\(image)",
                "link": {
                  "mobile_web_url": "https://developers.kakao.com",
                  "web_url": "https://developers.kakao.com"
                }
              },
              "buttons": [
                {
                  "title": "앱으로 보기",
                  "link": {
                    "android_execution_params": "boardId=\(detaildata?.id ?? 0)",
                    "ios_execution_params": "boardId=\(detaildata?.id ?? 0)"
                  }
                }
              ]
            }
            """.data(using: .utf8)!
            guard let templatable = try? SdkJSONDecoder.custom.decode(FeedTemplate.self, from: feedTemplateJsonStringData) else { return }
            if ShareApi.isKakaoTalkSharingAvailable() {
              ShareApi.shared.shareDefault(templatable: templatable) { sharingResult, error in
                if let sharingResult = sharingResult {
                    print(sharingResult.url)
                  UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
                }
              }
            }
  }
  
  func updateFood() {
    let vc = RegistUsedVC.viewController()
    vc.usedId = usedId
    self.navigationController?.pushViewController(vc, animated: true)
  }
    
  
  func updateFoodStatus() {
      let param = UpdateUsedRequest(
        statusSale: true
      )
      
      APIProvider.shared.usedAPI.rx.request(.complete(id: usedId, param: param))
        .filterSuccessfulStatusCodes()
        .subscribe(onSuccess: { response in
            self.callOkActionMSGDialog(message: "판매 완료되었습니다.") {
              self.backPress()
            }
          
        }, onError: { error in
          self.dismissHUD()
          self.callMSGDialog(message: "오류가 발생하였습니다")
        })
        .disposed(by: disposeBag)
  }
  
  func removeFood() {
      callYesNoMSGDialog(message: "삭제하시겠습니까?") {
          APIProvider.shared.usedAPI.rx.request(.remove(id: self.usedId))
            .filterSuccessfulStatusCodes()
            .map(DefaultResponse.self)
            .subscribe(onSuccess: { value in
                self.backPress()
            }, onError: { error in
            })
            .disposed(by: self.disposeBag)
      }
    
  }
  
  func reportFood() {
    let vc = FoodReportPopupVC.viewController()
    vc.delegate = self
    vc.usedId = usedId
    self.present(vc, animated: true)
  }
}

extension UsedDetailVC: FoodReportDelegate {
    func finishFoodReport(text: String,foodId:Int?, usedId:Int?) {
    let param = RegistReportRequest(content: text, foodId: foodId, usedId: usedId)
    APIProvider.shared.reportAPI.rx.request(.register(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
          self.callOkActionMSGDialog(message: "신고 완료되었습니다.") {
            self.backPress()
          }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
}


extension UsedDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if scrollView.isEqual(thumbnailCollectionView) {
      let page = Int(targetContentOffset.pointee.x / thumbnailCollectionView.bounds.width)
      print(page)
      thumbnailCountLabel.text = "\(page + 1)/\(thumbnailList.count)"
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == thumbnailCollectionView {
      return thumbnailList.count
    }else if collectionView == hashTagCollectionView{
      return hashTagList.count
    } else {
      return anotherUsedList.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == thumbnailCollectionView {
      let cell = thumbnailCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let dict = thumbnailList[indexPath.row]
      guard let imageView = cell.viewWithTag(1) as? UIImageView else {
        return cell
      }
      
      imageView.kf.setImage(with: URL(string: dict.name))
      return cell
    }else if collectionView == hashTagCollectionView{
      let cell = hashTagCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let dict = hashTagList[indexPath.row]
      guard let hashTagLabel = cell.viewWithTag(1) as? UILabel else {
        return cell
      }
      hashTagLabel.text = dict
      return cell
    } else {
      let cell = anotherUsedListCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FoodListCell
      let dict = anotherUsedList[indexPath.row]
      cell.update(dict)
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == thumbnailCollectionView {
      showImageList(imageList: thumbnailUIImageList, index: indexPath.row)
    } else if collectionView == hashTagCollectionView {
      let vc = SearchFoodAndUsedVC.viewController()
      vc.searchText = hashTagList[indexPath.row]
      vc.selectedDiff = .used
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
}

// MARK: - TableView
extension UsedDetailVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return commentList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "FoodCommentListCell") as! CommentListCell
    
    let dict = commentList[indexPath.row]
    cell.delegate = self
    cell.update(dict)
    
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}
