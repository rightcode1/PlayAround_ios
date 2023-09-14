 //
//  FoodDetailVC.swift
//  PlayAround
//
//  Created by haon on 2022/05/23.
//

import UIKit
import RxSwift
import IQKeyboardManagerSwift
import KakaoSDKTemplate
import KakaoSDKShare
import KakaoSDKCommon

struct ChatRoomHeaderData: Codable {
  let thumbnail: String?
  let name: String
  let title: String
}

class FoodDetailVC: BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var wishBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var thumbnailCollectionView: UICollectionView!
  @IBOutlet weak var thumbnailCountLabel: UILabel!
  
  @IBOutlet weak var foodStatusStackView: UIStackView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  @IBOutlet weak var userThumbnailImageView: UIImageView!
  @IBOutlet weak var userFoodLevelImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var wishCountLabel: UILabel!
  @IBOutlet weak var viewCountLabel: UILabel!
  @IBOutlet weak var checkCheatButton: UIButton!
  @IBOutlet weak var followButton: UIButton!
  
  @IBOutlet weak var foodRequestInfoView: UIView!
  @IBOutlet weak var dueDateLabel: UILabel!
  @IBOutlet weak var possibleRequestCountLabel: UILabel!
  @IBOutlet weak var requestPeopleCountLabel: UILabel!
  @IBOutlet weak var finishRequestButton: UIButton!
  @IBOutlet weak var requestButton: UIButton!
  
  @IBOutlet weak var likeButton: UIImageView!
  @IBOutlet weak var dislikeButton: UIImageView!
  @IBOutlet weak var likeCountLabel: UILabel!
  @IBOutlet weak var disLikeCountLabel: UILabel!
  
  @IBOutlet weak var foodContentLabel: UILabel!
  @IBOutlet weak var hashTagCollectionView: UICollectionView!
  
  @IBOutlet weak var allergyCollectionView: UICollectionView!
  @IBOutlet weak var allergyCollectionVIewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var userNameLabel2: UILabel!
  @IBOutlet weak var anotherFoodView: UIStackView!
  @IBOutlet weak var anotherFoodListCollectionView: UICollectionView!
  
  @IBOutlet weak var commentCountlabel: UILabel!
  @IBOutlet weak var registCommentButton: UIButton!
    
    @IBOutlet weak var soldOutView: UIView!
    
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
  
  var foodId: Int = -1
  
  var isMine: Bool = false
  
  var thumbnailList: [Image] = []
  var thumbnailUIImageList: [UIImage] = []
  
  var foodUserId: Int = -1
  let isFollow = BehaviorSubject<Bool>(value: false)
  
  var isEndRequest = false
  var isFullRequest = false
  var isRequest = false
    
    var data:FoodDetailData?
  
  let isWish = BehaviorSubject<Bool>(value: false)
  
  let isLike = BehaviorSubject<Bool?>(value: nil)
  let likeCount = BehaviorSubject<Int>(value: 0)
  let dislikeCount = BehaviorSubject<Int>(value: 0)
  
  let allergyList: [FoodAllergy] = [.없음, .갑각류, .생선, .메밀복숭아, .견과류, .달걀, .우유]
  var selectedAllergyList: [FoodAllergy] = []
  
  var anotherFoodList: [FoodListData] = []
  
  var replyCommentId: Int?
  var commentList: [FoodCommentListData] = []
  var hashTagList: [String] = []
  
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
      self.initFoodDetail()
    setTextViewHeight()
  }
  
  override func viewDidLayoutSubviews() {
    tableView.layoutTableHeaderView()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    IQKeyboardManager.shared.enableAutoToolbar = true
  }
  
  static func viewController() -> FoodDetailVC {
    let viewController = FoodDetailVC.viewController(storyBoardName: "Food")
    return viewController
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
    self.view.endEditing(true)
    self.tableView.endEditing(true)
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
    
    allergyCollectionView.delegate = self
    allergyCollectionView.dataSource = self
    
    anotherFoodListCollectionView.delegate = self
    anotherFoodListCollectionView.dataSource = self
    
    hashTagCollectionView.delegate = self
    hashTagCollectionView.dataSource = self
    
    setThumbnailCollectionViewLayout()
    setAllergyCollectionViewLayout()
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
  
  func setAllergyCollectionViewLayout() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    let width = (APP_WIDTH() - 30) / 7
    layout.itemSize = CGSize(width: width, height: width + 5.5)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.invalidateLayout()
    allergyCollectionView.collectionViewLayout = layout
    allergyCollectionVIewHeightConstraint.constant = width + 5.5
  }
  
  func setAnotherFoodListCollectionViewLayout() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    layout.itemSize = CGSize(width: (APP_WIDTH() - 60) / 2, height: 170)
    layout.minimumInteritemSpacing = 10
    layout.minimumLineSpacing = 10
    layout.scrollDirection = .horizontal
    layout.invalidateLayout()
    anotherFoodListCollectionView.collectionViewLayout = layout
  }
  
  func initFollowButton(_ isFollow: Bool) {
    followButton.backgroundColor = isFollow ? .white : UIColor(red: 243/255, green: 112/255, blue: 34/255, alpha: 1.0)
    followButton.layer.borderWidth = isFollow ? 1 : 0
    followButton.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0).cgColor
    followButton.setTitleColor(isFollow ? UIColor(red: 188/255, green: 188/255, blue: 188/255, alpha: 1.0) : .white, for: .normal)
    followButton.setTitle(isFollow ? "팔로잉" : "+팔로우", for: .normal)
  }
  
  func initRequstButton() {
    let orangeBackGroundColor = UIColor(red: 255/255, green: 200/255, blue: 117/255, alpha: 1.0)
    let cancelBackGroundColor = UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1.0)
    
    if isMine {
      requestButton.setTitle("신청인 보기", for: .normal)
      requestButton.backgroundColor = orangeBackGroundColor
    } else {
      requestButton.setTitle(isRequest ? "신청취소" : "신청하기", for: .normal)
      requestButton.backgroundColor = isRequest ? cancelBackGroundColor : orangeBackGroundColor
    }
  }
  
  func initFoodDetail() {
    self.showHUD()
    APIProvider.shared.foodAPI.rx.request(.foodDetail(id: foodId))
      .filterSuccessfulStatusCodes()
      .map(FoodDetailResponse.self)
      .subscribe(onSuccess: { value in
        guard let data = value.data else { return }
        self.initAnotherFoodList(userId: value.data?.userId ?? 0)
        self.navigationItem.title = data.category.rawValue
        
        self.thumbnailList = data.images
        DispatchQueue.main.async {
          self.thumbnailUIImageList = self.initUIImageList(data.images)
        }
        self.thumbnailCountLabel.text = "1/\(self.thumbnailList.count)"
        self.thumbnailCollectionView.reloadData()
          
          self.soldOutView.isHidden = !data.statusSale!
        if data.statusSale! || data.user.id == DataHelperTool.userAppId{
                self.chatButton.backgroundColor = .systemGray3
                self.chatButton.setTitle("나눔완료", for: .normal)
      }
          
        self.selectedAllergyList = data.allergy
        self.allergyCollectionView.reloadData()
        
        self.foodStatusStackView.arrangedSubviews[0].isHidden = data.status == .조리완료
        self.foodStatusStackView.arrangedSubviews[1].isHidden = data.status == .조리예정
      
        self.isWish.onNext(data.isWish)
        self.titleLabel.text = data.name
        self.priceLabel.text = "\(data.price.formattedProductPrice() ?? "0")원"
        
        let userData = data.user
        self.foodUserId = userData.id
        if userData.thumbnail != nil {
          self.userThumbnailImageView.kf.setImage(with: URL(string: userData.thumbnail ?? ""))
        } else {
          self.userThumbnailImageView.image = UIImage(named: "defaultBoardImage")
        }
        self.userFoodLevelImageView.image = self.foodLevelImage(level: userData.foodLevel ?? 1)
        self.userNameLabel.text = userData.name
        self.userNameLabel2.text = userData.name

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let createdAtDate = dateFormatter.date(from: data.createdAt) {
          self.dateLabel.text = createdAtDate.toString(dateFormat: "yyyy.MM.dd")
        } else {
          self.dateLabel.text = data.createdAt
        }
        
        self.wishCountLabel.text = "\(data.wishCount)"
        self.viewCountLabel.text = "조회 \(data.viewCount)"
        self.isFollow.onNext(userData.isFollowing)
        
        self.isMine = data.userId == DataHelperTool.userAppId ?? 0
        self.isEndRequest = Date() > data.dueDate?.stringToDate ?? Date()
        self.isFullRequest = (data.userCount ?? 0) <= (data.requestCount ?? 0)
          
        self.foodRequestInfoView.isHidden = data.status == .조리완료
        self.dueDateLabel.text = data.dueDate
        
        if self.isFullRequest {
          self.possibleRequestCountLabel.text = "마감"
          self.requestPeopleCountLabel.text = "마감"
          
          self.requestButton.isHidden = true
          self.finishRequestButton.isHidden = false
        } else {
          self.possibleRequestCountLabel.text = "\(data.requestCount ?? 0)"
          self.requestPeopleCountLabel.text = "\(data.userCount ?? 0)"
          
          self.finishRequestButton.isHidden = true
          self.requestButton.isHidden = false
        }
        self.initRequstButton()
        
        self.foodContentLabel.text = data.content
        self.hashTagList = data.hashtag.map({ "#\($0)" })
        self.hashTagCollectionView.reloadData()
        
        self.isLike.onNext(data.isLike)
        self.likeCount.onNext(data.likeCount)
        self.dislikeCount.onNext(data.dislikeCount)
        
        self.initCommentList()
        
        let chatRoomHeaderData = ChatRoomHeaderData(thumbnail: data.images.count > 0 ? data.images[0].name : nil, name: data.user.name, title: data.name)
        self.chatRoomHeaderData = chatRoomHeaderData
          self.data = data
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initAnotherFoodList(userId: Int) {
    let param = FoodListRequest(userId: userId)
    APIProvider.shared.foodAPI.rx.request(.foodList(param: param))
      .filterSuccessfulStatusCodes()
      .map(FoodListResponse.self)
      .subscribe(onSuccess: { value in
        self.anotherFoodList = value.list
        self.anotherFoodView.isHidden = value.list.count <= 0
        self.anotherFoodListCollectionView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initCommentList() {
    APIProvider.shared.foodCommnetAPI.rx.request(.foodCommentList(foodId: foodId))
      .filterSuccessfulStatusCodes()
      .map(FoodCommentListResponse.self)
      .subscribe(onSuccess: { value in
        self.commentList = value.list
        self.commentCountlabel.text = "\(value.list.count)"
        self.tableView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func registWish() {
    let param = RegistFoodWishRequest(foodId: foodId)
    APIProvider.shared.foodWishAPI.rx.request(.wishRegister(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.initFoodDetail()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func removeWish() {
    APIProvider.shared.foodWishAPI.rx.request(.wishRemove(foodId: foodId))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.initFoodDetail()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func registLike(isLike: Bool) {
    let param = RegistFoodLikeRequest(isLike: isLike, foodId: foodId)
    APIProvider.shared.foodLikeAPI.rx.request(.likeRegister(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.initFoodDetail()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func removeLike() {
    APIProvider.shared.foodLikeAPI.rx.request(.likeRemove(id: foodId))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.initFoodDetail()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func registFollow() {
    let param = RegistFollowRequest(userId: foodUserId)
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
    APIProvider.shared.followAPI.rx.request(.remove(userId: foodUserId))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.isFollow.onNext(false)
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func registComment() {
    let param = RegistFoodCommentRequest(foodId: foodId, content: inputTextView.text!, foodCommentId: replyCommentId)
    APIProvider.shared.foodCommnetAPI.rx.request(.foodCommentRegister(param: param))
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
    let param = RegistChatRoomRequest(foodId: foodId, userId: foodUserId)
    APIProvider.shared.chatAPI.rx.request(.roomRegister(param: param))
      .filterSuccessfulStatusCodes()
      .map(RegistChatRoomResponse.self)
      .subscribe(onSuccess: { value in
        
        let vc = ChatVC.viewController()
        vc.foodId = self.foodId
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
        if try! self.isLike.value() != nil {
          self.removeLike()
        } else {
          self.registLike(isLike: true)
        }
      })
      .disposed(by: disposeBag)
    
    dislikeButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if try! self.isLike.value() != nil {
          self.removeLike()
        } else {
          self.registLike(isLike: false)
        }
      })
      .disposed(by: disposeBag)
    
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
    requestButton.rx.tap
        .bind(onNext: { [weak self] in
          guard let self = self else { return }
            if !self.isMine {
                let param = FoodjoinRequest(foodId: self.foodId)
                APIProvider.shared.foodAPI.rx.request(.foodregister(param: param))
                  .filterSuccessfulStatusCodes()
                  .map(DefaultResponse.self)
                  .subscribe(onSuccess: { value in
                      self.okActionAlert(message: "신청되었습니다.") {
                          self.initFoodDetail()
                      }
                  }, onError: { error in
                  })
                  .disposed(by: self.disposeBag)
            }else{
                if self.data?.foodUsers.isEmpty ?? false{
                    self.callOkActionMSGDialog(message: "신청인이 없습니다.") {
                    }
                }else{
                    let vc = FoodUserListVC.viewController()
                    vc.foodId = self.foodId
                    vc.foodUserList = self.data?.foodUsers ?? []
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        })
        .disposed(by: disposeBag)
  }
  
  func bindOutput() {
    isLike.bind(onNext: { [weak self] isLike in
        guard let self = self else { return }
        if let bool = isLike {
          self.likeButton.image = bool ? UIImage(named: "like") : UIImage(named: "likeoff")
          self.dislikeButton.image = !bool ? UIImage(named: "dislike") : UIImage(named: "dislikeoff")
        } else {
          self.likeButton.image = UIImage(named: "likeoff")
          self.dislikeButton.image = UIImage(named: "dislikeoff")
        }
      })
      .disposed(by: disposeBag)
    
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
    
    likeCount
      .bind(onNext: { [weak self] count in
        guard let self = self else { return }
        self.likeCountLabel.text = "\(count)"
      }).disposed(by: disposeBag)
    
    dislikeCount
      .bind(onNext: { [weak self] count in
        guard let self = self else { return }
        self.disLikeCountLabel.text = "\(count)"
      }).disposed(by: disposeBag)
  }
  
}

extension FoodDetailVC: UITextViewDelegate {
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

extension FoodDetailVC: FoodCommentListCellDelegate {
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

extension FoodDetailVC: CheckCrimeHistoryDelegate {
  func moveToCheckCheatWithWeb(urlString: String) {
    openUrl(urlString)
  }
}

extension FoodDetailVC: FoodDetailMenuDelegate {
  func shareFood() {
      var image = ""
      if data?.images.count != 0{
          image = data?.images[0].name ?? ""
      }
      let feedTemplateJsonStringData =
      """
      {
        "object_type": "feed",
        "content": {
          "title": "\(data?.name ?? "")",
          "description": "\(data?.hashtag.map({ "#\($0)" }).joined(separator: " ") ?? "")",
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
              "android_execution_params": "boardId=\(data?.id ?? 0)",
              "ios_execution_params": "boardId=\(data?.id ?? 0)"
            }
          }
        ]
      }
      """.data(using: .utf8)!

      guard let templatable = try? SdkJSONDecoder.custom.decode(FeedTemplate.self, from: feedTemplateJsonStringData) else { return }
      if ShareApi.isKakaoTalkSharingAvailable() {
        ShareApi.shared.shareDefault(templatable: templatable) { sharingResult, error in
          if let sharingResult = sharingResult {
            UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
          }
        }
      }
  }
  
  func updateFood() {
    let vc = RegistFoodVC.viewController()
    vc.foodId = foodId
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func updateFoodStatus() {
      print("!!!")
      let param = FoodUpdateRequest(
        statusSale: true
      )
      showHUD()
        APIProvider.shared.foodAPI.rx.request(.complete(id: foodId, param: param))
          .filterSuccessfulStatusCodes()
          .subscribe(onSuccess: { response in
              self.dismissHUD()
              self.callOkActionMSGDialog(message: "판매 완료되었습니다") {
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
          APIProvider.shared.foodAPI.rx.request(.remove(id: self.foodId))
            .filterSuccessfulStatusCodes()
            .subscribe(onSuccess: { response in
                self.backPress()
              
            }, onError: { error in
              self.callMSGDialog(message: "오류가 발생하였습니다")
            })
            .disposed(by: self.disposeBag)
      }
  }
  
  func reportFood() {
    let vc = FoodReportPopupVC.viewController()
    vc.delegate = self
    vc.foodId = foodId
    self.present(vc, animated: true)
  }
}

extension FoodDetailVC: FoodReportDelegate {
    func finishFoodReport(text: String,foodId:Int?, usedId:Int?) {
        
    let param = RegistReportRequest(content: text, foodId: foodId, usedId: usedId)
    APIProvider.shared.reportAPI.rx.request(.register(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
          self.dismissHUD()
          self.callOkActionMSGDialog(message: "신고가 완료되었습니다") {
            self.backPress()
          }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
}


extension FoodDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    } else if collectionView == allergyCollectionView {
      return allergyList.count
    }else if collectionView == hashTagCollectionView{
      return hashTagList.count
    } else {
      return anotherFoodList.count
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
    } else if collectionView == allergyCollectionView {
      let cell = allergyCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let dict = allergyList[indexPath.row]
      guard let imageView = cell.viewWithTag(1) as? UIImageView else {
        return cell
      }
      imageView.image = selectedAllergyList.contains(dict) ? dict.onImage() : dict.offImage()
      if selectedAllergyList.contains(dict){
        print(dict)
      }
      return cell
    }else if collectionView == hashTagCollectionView{
      let cell = hashTagCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let dict = hashTagList[indexPath.row]
      guard let hashTagLabel = cell.viewWithTag(1) as? UILabel else {
        return cell
      }
      hashTagLabel.text = dict
      return cell
    }  else {
      let cell = anotherFoodListCollectionView.dequeueReusableCell(withReuseIdentifier: "anothercell", for: indexPath) as! FoodListCell
      let dict = anotherFoodList[indexPath.row]
      cell.update(dict, isDetail: "detail")
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == thumbnailCollectionView {
      showImageList(imageList: thumbnailUIImageList, index: indexPath.row)
    } else if collectionView == hashTagCollectionView {
      let vc = SearchFoodAndUsedVC.viewController()
      vc.searchText = hashTagList[indexPath.row]
      vc.selectedDiff = .food
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
}

// MARK: - TableView
extension FoodDetailVC: UITableViewDelegate, UITableViewDataSource {
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
