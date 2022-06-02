//
//  FoodDetailVC.swift
//  PlayAround
//
//  Created by haon on 2022/05/23.
//

import UIKit
import RxSwift

class FoodDetailVC: BaseViewController {
  @IBOutlet weak var wishBarButtonItem: UIBarButtonItem!
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
  
  @IBOutlet weak var userNameLabel2: UILabel!
  @IBOutlet weak var anotherFoodListCollectionView: UICollectionView!
  
  @IBOutlet weak var commentCountlabel: UILabel!
  @IBOutlet weak var registCommentButton: UIButton!
  
  var foodId: Int = -1
  
  var isMine: Bool = false
  
  var thumbnailList: [Image] = []
  
  let isFollow = BehaviorSubject<Bool>(value: false)
  
  var isEndRequest = false
  var isFullRequest = false
  var isRequest = false
  
  let isLike = BehaviorSubject<Bool?>(value: nil)
  
  let allergyList: [FoodAllergy] = [.없음, .갑각류, .생선, .메밀복숭아, .견과류, .달걀, .우유]
  var selectedAllergyList: [FoodAllergy] = []
  
  var anotherFoodList: [FoodListData] = []
  
  var commentList: [FoodCommentListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setCollectionView()
    bindInput()
    bindOutput()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    initUserInfo()
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
    thumbnailCollectionView.collectionViewLayout = layout
  }
  
  func setAllergyCollectionViewLayout() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    let width = (APP_WIDTH() - 72) / 7
    layout.itemSize = CGSize(width: width, height: width + 5.5)
    layout.minimumInteritemSpacing = 6
    layout.minimumLineSpacing = 6
    layout.invalidateLayout()
    allergyCollectionView.collectionViewLayout = layout
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
        self.selectedAllergyList = data.allergy
        self.foodStatusStackView.arrangedSubviews[0].isHidden = data.status == .조리예정
        self.foodStatusStackView.arrangedSubviews[1].isHidden = data.status == .조리완료
      
        self.titleLabel.text = data.name
        self.priceLabel.text = "\(data.price.formattedProductPrice() ?? "0") 달란트"
        
        let userData = data.user
        self.userThumbnailImageView.kf.setImage(with: URL(string: userData.thumbnail ?? ""))
        self.userFoodLevelImageView.image = self.foodLevelImage(level: userData.foodLevel ?? 1)
        self.userNameLabel.text = userData.name
        self.dateLabel.text = data.createdAt
        self.wishCountLabel.text = "\(data.wishCount)"
        self.viewCountLabel.text = "\(data.viewCount)"
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
        
        self.likeCountLabel.text = "좋아요 \(data.likeCount)"
        self.disLikeCountLabel.text = "싫어요 \(data.dislikeCount)"
        
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func bindInput() {
    
  }
  
  func bindOutput() {
    isLike
      .bind(onNext: { [weak self] isLike in
        guard let self = self else { return }
        if let bool = isLike {
          
        } else {
          
        }
      })
      .disposed(by: disposeBag)
    
    isFollow
      .bind(onNext: { [weak self] isFollow in
        guard let self = self else { return }
        
      })
      .disposed(by: disposeBag)
  }
  
}

extension FoodDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if scrollView.isEqual(thumbnailCollectionView) {
      let page = Int(targetContentOffset.pointee.x / thumbnailCollectionView.bounds.width)
      print(page)
      thumbnailCountLabel.text = "\(page)/\(thumbnailList.count)"
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
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let dict = thumbnailList[indexPath.row]
      guard let imageView = cell.viewWithTag(1) as? UIImageView else {
        return cell
      }
      
      imageView.kf.setImage(with: URL(string: dict.name))
      return cell
    } else if collectionView == allergyCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      let dict = allergyList[indexPath.row]
      guard let imageView = cell.viewWithTag(1) as? UIImageView else {
        return cell
      }
      
      imageView.image = selectedAllergyList.contains(dict) ? dict.onImage() : dict.offImage()
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FoodListCell
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
