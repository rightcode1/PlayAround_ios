//
//  FoodDetailVC.swift
//  PlayAround
//
//  Created by haon on 2022/05/23.
//

import UIKit
import RxSwift
import IQKeyboardManagerSwift

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
  @IBOutlet weak var hashtagLabel: UILabel!
  
  @IBOutlet weak var allergyCollectionView: UICollectionView!
  @IBOutlet weak var allergyCollectionVIewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var userNameLabel2: UILabel!
  @IBOutlet weak var anotherFoodView: UIStackView!
  @IBOutlet weak var anotherFoodListCollectionView: UICollectionView!
  
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
  
  @IBOutlet weak var registCommentButton2: UIButton!
  
  @IBOutlet weak var chatButton: UIButton!
  
  var foodId: Int = -1
  
  var isMine: Bool = false
  
  var thumbnailList: [Image] = []
  
  var foodUserId: Int = -1
  let isFollow = BehaviorSubject<Bool>(value: false)
  
  var isEndRequest = false
  var isFullRequest = false
  var isRequest = false
  
  let isWish = BehaviorSubject<Bool>(value: false)
  
  let isLike = BehaviorSubject<Bool?>(value: nil)
  let likeCount = BehaviorSubject<Int>(value: 0)
  let dislikeCount = BehaviorSubject<Int>(value: 0)
  
  let allergyList: [FoodAllergy] = [.없음, .갑각류, .생선, .메밀복숭아, .견과류, .달걀, .우유]
  var selectedAllergyList: [FoodAllergy] = []
  
  var anotherFoodList: [FoodListData] = []
  
  var replyCommentId: Int?
  var commentList: [FoodCommentListData] = []
  
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
        } else {
          self.inputTextBottomConst.constant = keyboardRect.height
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
  
  func initUserInfo() {
    userInfo() { result in
      self.initFoodDetail()
      self.initAnotherFoodList(userId: result.data.id)
    }
  }
  
  func initFoodDetail() {
    self.showHUD()
    APIProvider.shared.foodAPI.rx.request(.foodDetail(id: foodId))
      .filterSuccessfulStatusCodes()
      .map(FoodDetailResponse.self)
      .subscribe(onSuccess: { value in
        guard let data = value.data else { return }
        
        self.thumbnailList = data.images
        self.thumbnailCountLabel.text = "1/\(self.thumbnailList.count)"
        self.thumbnailCollectionView.reloadData()
        
        self.selectedAllergyList = data.allergy
        
        self.foodStatusStackView.arrangedSubviews[0].isHidden = data.status == .조리예정
        self.foodStatusStackView.arrangedSubviews[1].isHidden = data.status == .조리완료
      
        self.isWish.onNext(data.isWish)
        self.titleLabel.text = data.name
        self.priceLabel.text = "\(data.price.formattedProductPrice() ?? "0") 달란트"
        
        let userData = data.user
        self.foodUserId = userData.id
        self.userThumbnailImageView.kf.setImage(with: URL(string: userData.thumbnail ?? ""))
        self.userFoodLevelImageView.image = self.foodLevelImage(level: userData.foodLevel ?? 1)
        self.userNameLabel.text = userData.name
        self.dateLabel.text = data.createdAt
        self.wishCountLabel.text = "\(data.wishCount)"
        self.viewCountLabel.text = "조회 \(data.viewCount)"
        self.isFollow.onNext(userData.isFollowing)
        
        self.isMine = data.userId == DataHelperTool.userAppId ?? 0
        self.isEndRequest = Date() > data.dueDate?.stringToDate ?? Date()
        self.isFullRequest = (data.requestCount ?? 0) <= (data.userCount ?? 0)
        
        self.foodRequestInfoView.isHidden = self.isEndRequest
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
        let hashTagList = data.hashtag.map({ "#\($0)" })
        self.hashtagLabel.text = hashTagList.joined(separator: " ")
        
        self.isLike.onNext(data.isLike)
        self.likeCount.onNext(data.likeCount)
        self.dislikeCount.onNext(data.dislikeCount)
        
        self.initCommentList()
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
  }
  
  func bindOutput() {
    isLike
      .bind(onNext: { [weak self] isLike in
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
        self.likeCountLabel.text = "좋아요 \(count)"
      }).disposed(by: disposeBag)
    
    dislikeCount
      .bind(onNext: { [weak self] count in
        guard let self = self else { return }
        self.disLikeCountLabel.text = "싫어요 \(count)"
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
    
  }
  
  func updateFood() {
    let vc = RegistFoodVC.viewController()
    vc.foodId = foodId
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func updateFoodStatus() {
    
  }
  
  func removeFood() {
    
  }
  
  func reportFood() {
    let vc = FoodReportPopupVC.viewController()
    vc.delegate = self
    vc.foodId = foodId
    self.present(vc, animated: true)
  }
}

extension FoodDetailVC: FoodReportDelegate {
  func finishFoodReport() {
    showToast(message: "신고가 완료되었습니다.", yPosition: APP_HEIGHT() / 2)
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
      return cell
    } else {
      let cell = anotherFoodListCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FoodListCell
      let dict = anotherFoodList[indexPath.row]
      cell.update(dict, isDetail: "detail")
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == thumbnailCollectionView {
      
    } else if collectionView == allergyCollectionView {
      
    } else {
      
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
