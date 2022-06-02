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
  
  @IBOutlet weak var foodContentLabel: UILabel!
  @IBOutlet weak var hashtagLabel: UILabel!
  
  @IBOutlet weak var likeButton: UIImageView!
  @IBOutlet weak var dislikeButton: UIImageView!
  @IBOutlet weak var likeCountLabel: UILabel!
  @IBOutlet weak var disLikeCountLabel: UILabel!
  
  var foodId: Int = -1
  
  var isMine: Bool = false
  
  var thumbnailList: [Image] = []
  
  let isFollow = BehaviorSubject<Bool>(value: false)
  let isLike = BehaviorSubject<Bool?>(value: nil)
  let isRequest = false
  let isEndRequest = false
  
  let allergyList: [FoodAllergy] = [.없음, .갑각류, .생선, .메밀복숭아, .견과류, .달걀, .우유]
  let selectedAllergyList: [FoodAllergy] = []
  
  var anotherFoodList: [FoodList] = []
  
  var commentList: [FoodCommentListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
      
  }
  
  func initFollowButton(_ isFollow: Bool) {
    followButton.backgroundColor = isFollow ? .white : UIColor(red: 243/255, green: 112/255, blue: 34/255, alpha: 1.0)
    followButton.layer.borderWidth = isFollow ? 1 : 0
    followButton.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0).cgColor
    followButton.setTitle(isFollow ? "팔로잉" : "+팔로우", for: .normal)
  }
  
  func initFoodDetail() {
    self.showHUD()
    APIProvider.shared.foodAPI.rx.request(.foodDetail(id: foodId))
      .filterSuccessfulStatusCodes()
      .map(FoodDetailResponse.self)
      .subscribe(onSuccess: { value in
        
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
        
      })
      .disposed(by: disposeBag)
    
    isFollow
      .bind(onNext: { [weak self] isFollow in
        guard let self = self else { return }
        
      })
      .disposed(by: disposeBag)
  }
  
}
