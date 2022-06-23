//
//  MyPageVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/22.
//

import UIKit
import RxSwift

enum MyPageDiff: String, Codable {
  case community = "커뮤니티"
  case food = "반찬공유"
  case used = "중고거래"
}

class MyPageVC: BaseViewController, ViewControllerFromStoryboard {
  
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var updateInfoButton: UIButton!
  
  @IBOutlet weak var communityLevelImage: UIImageView!
  @IBOutlet weak var foodLevelImage: UIImageView!
  @IBOutlet weak var usedLevelImage: UIImageView!
  
  @IBOutlet weak var showFollowingButton: UIButton!
  @IBOutlet weak var showFollowerButton: UIButton!
  @IBOutlet weak var registFollowButton: UIButton!
  
  @IBOutlet weak var diffCollectionView: UICollectionView!
  @IBOutlet weak var listCollectionView: UICollectionView!
  @IBOutlet weak var listCollectionViewHeightConstraint: NSLayoutConstraint!
  
  var showUserId: Int?
  var userId: Int?
  
  private let diffList: [MyPageDiff] = [.community, .food, .used]
  private var selectedDiff: MyPageDiff = .community
  
  private var communityList: [CommuintyList] = []
  private var foodList: [FoodListData] = []
  private var usedList: [UsedListData] = []
  
  private var followingList: [Follow] = []
  private var followerList: [Follow] = []
  
  let isFollow = BehaviorSubject<Bool>(value: false)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setCollectionViews()
    bindInput()
    bindOutput()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    initUserInfo()
  }
  
  static func viewController() -> MyPageVC {
    let viewController = MyPageVC.viewController(storyBoardName: "MyPage")
    return viewController
  }
  
  func initFollowButton(_ isFollowing: Bool) {
    registFollowButton.backgroundColor = isFollowing ? .white : UIColor(red: 243/255, green: 112/255, blue: 34/255, alpha: 1.0)
    registFollowButton.layer.borderWidth = isFollowing ? 1 : 0
    registFollowButton.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0).cgColor
    registFollowButton.setTitleColor(isFollowing ? UIColor(red: 188/255, green: 188/255, blue: 188/255, alpha: 1.0) : .white, for: .normal)
    registFollowButton.setTitle(isFollowing ? "팔로잉" : "팔로우", for: .normal)
  }
  
  func setCollectionViews() {
    diffCollectionView.delegate = self
    diffCollectionView.dataSource = self
    
    listCollectionView.delegate = self
    listCollectionView.dataSource = self
  }
  
  func initUserInfo() {
    userInfo(showUserId) { result in
      self.userId = result.data.id
      
      self.isFollow.onNext(result.data.isFollowing)
      self.followingList = result.data.followings ?? []
      self.followerList = result.data.followers ?? []
      
      print("DataHelperTool.userAppId : \(DataHelperTool.userAppId ?? 0)")
      let isMine = (DataHelperTool.userAppId ?? 0) == self.userId
      
      self.updateInfoButton.isHidden = !isMine
      
      self.showFollowingButton.isHidden = !isMine
      self.showFollowerButton.isHidden = !isMine
      self.registFollowButton.isHidden = isMine
      self.initFollowButton(result.data.isFollowing)
      
      
      if result.data.thumbnail == nil {
        self.userImageView.image = UIImage(named: "defaultProfileImage")
      } else {
        self.userImageView.kf.setImage(with: URL(string: result.data.thumbnail ?? ""))
      }
      self.userNameLabel.text = result.data.name
      
      self.communityLevelImage.image = self.communityLevelImage(level: result.data.communityLevel ?? 1)
      self.foodLevelImage.image = self.foodLevelImage(level: result.data.foodLevel ?? 1)
      self.usedLevelImage.image = self.usedLevelImage(level: result.data.usedLevel ?? 1)
      
      self.initList()
    }
  }
  
  func initList() {
    switch selectedDiff {
    case .community:
      initCommunityList()
    case .food:
      initFoodList()
    case .used:
      initUsedList()
    }
  }
  
  func initCommunityList() {
    let param = categoryListRequest(userId: self.userId ?? 0)
    APIProvider.shared.communityAPI.rx.request(.CommuntyList(param: param))
      .filterSuccessfulStatusCodes()
      .map(CommunityResponse.self)
      .subscribe(onSuccess: { value in
        self.communityList = value.list
        self.listCollectionViewHeightConstraint.constant = (CGFloat(value.list.count) * 115) + 5
        self.listCollectionView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initFoodList() {
    let param = FoodListRequest(userId: self.userId ?? 0)
    APIProvider.shared.foodAPI.rx.request(.foodList(param: param))
      .filterSuccessfulStatusCodes()
      .map(FoodListResponse.self)
      .subscribe(onSuccess: { value in
        self.foodList = value.list
        let plusCount = value.list.count % 2
        self.listCollectionViewHeightConstraint.constant = (CGFloat((value.list.count / 2) + plusCount) * 205) + 15
        self.listCollectionView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initUsedList() {
    let param = UsedListRequest(userId: self.userId ?? 0)
    APIProvider.shared.usedAPI.rx.request(.list(param: param))
      .filterSuccessfulStatusCodes()
      .map(UsedListResponse.self)
      .subscribe(onSuccess: { value in
        self.usedList = value.list
        let plusCount = value.list.count % 2
        self.listCollectionViewHeightConstraint.constant = (CGFloat((value.list.count / 2) + plusCount) * 185) + 15
        self.listCollectionView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func registFollow() {
    let param = RegistFollowRequest(userId: userId ?? 0)
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
    APIProvider.shared.followAPI.rx.request(.remove(userId: userId ?? 0))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.isFollow.onNext(false)
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func bindInput() {
    showFollowingButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = FollowListVC.viewController()
        vc.isFollowing = true
        vc.followList = self.followingList
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    showFollowerButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = FollowListVC.viewController()
        vc.isFollowing = false
        vc.followList = self.followerList
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    registFollowButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if try! self.isFollow.value() {
          self.removeFollow()
        } else {
          self.registFollow()
        }
      })
      .disposed(by: disposeBag)
  }
  
  func bindOutput() {
    isFollow
      .bind(onNext: { [weak self] isFollow in
        guard let self = self else { return }
        self.initFollowButton(isFollow)
      })
      .disposed(by: disposeBag)
  }
  
}

extension MyPageVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if diffCollectionView == collectionView {
      return diffList.count
    } else {
      switch selectedDiff {
      case .community:
        return communityList.count
      case .food:
        return foodList.count
      case .used:
        return usedList.count
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if diffCollectionView == collectionView {
      let cell = diffCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      let dict = diffList[indexPath.row]
      
      let selectedTextColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
      let defaultTextColor = UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0)
      
      (cell.viewWithTag(1) as! UILabel).text = dict.rawValue
      (cell.viewWithTag(1) as! UILabel).textColor = dict != selectedDiff ? defaultTextColor : selectedTextColor
      
      (cell.viewWithTag(2)!).isHidden = dict != selectedDiff
      
      return cell
    } else {
      if selectedDiff == .community {
        let cell = listCollectionView.dequeueReusableCell(withReuseIdentifier: "MyPageCommunityCollectionViewCell", for: indexPath) as! MyPageCommunityCollectionViewCell

        let dict = communityList[indexPath.row]
        cell.update(dict)
        
        return cell
      } else {
        let cell = listCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FoodListCell
        
        if selectedDiff == .food {
          let dict = foodList[indexPath.row]
          cell.update(dict)
        } else {
          let dict = usedList[indexPath.row]
          cell.update(dict)
        }
        
        return cell
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if diffCollectionView == collectionView {
      let dict = diffList[indexPath.row]
      
      selectedDiff = dict
      diffCollectionView.reloadData()
      initList()
    } else {
      switch selectedDiff {
      case .community:
        let dict = communityList[indexPath.row]
        let vc = CommunityDetailVC.viewController()
        vc.communityId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      case .food:
        let dict = foodList[indexPath.row]
        let vc = FoodDetailVC.viewController()
        vc.foodId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      case .used:
        let dict = usedList[indexPath.row]
        let vc = UsedDetailVC.viewController()
        vc.usedId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    if diffCollectionView == collectionView {
      return 13
    } else {
      return selectedDiff == .community ? 0 : 10
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    if diffCollectionView == collectionView {
      return 0
    } else {
      return selectedDiff == .community ? 0 : 10
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    if diffCollectionView == collectionView {
       return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    } else {
      switch selectedDiff {
      case .community:
        return UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
      case .food:
        return UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
      case .used:
        return UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if diffCollectionView == collectionView {
      let dict = diffList[indexPath.row]
      let width = textWidth(text: dict.rawValue, font: .systemFont(ofSize: 12, weight: .medium)) + 18

      return CGSize(width: width, height: 30)
    } else {
      let communityCellSize = CGSize(width: (APP_WIDTH()), height: 115)
      let foodCellSize = CGSize(width: (APP_WIDTH() - 40) / 2, height: 195)
      let usedCellSize = CGSize(width: (APP_WIDTH() - 40) / 2, height: 175)
      
      switch selectedDiff {
      case .community:
        return communityCellSize
      case .food:
        return foodCellSize
      case .used:
        return usedCellSize
      }
    }
  }
}
