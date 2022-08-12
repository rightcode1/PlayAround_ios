//
//  FoodVC.swift
//  PlayAround
//
//  Created by haon on 2022/05/23.
//

import UIKit

class FoodVC: BaseViewController, FoodCategoryReusableViewDelegate {
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var filterButton: UIButton!
  @IBOutlet weak var foodListCollectionView: UICollectionView!
  
  var category: FoodCategory = .전체
  var foodList: [FoodListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setFoodListCollectionViewLayout()
    bindInput()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
    initFoodList()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
  }
  
  func setFoodListCollectionViewLayout() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    layout.itemSize = CGSize(width: (APP_WIDTH() - 40) / 2, height: 195)
    layout.minimumInteritemSpacing = 10
    layout.minimumLineSpacing = 10
    layout.headerReferenceSize = CGSize(width: APP_WIDTH(), height: 87)
    layout.invalidateLayout()
    foodListCollectionView.collectionViewLayout = layout
  }
  
  func initFoodList(sort: FoodSort? = nil) {
    self.showHUD()
    let param = FoodListRequest(category: category == .전체 ? nil : category, sort: sort == nil ? .최신순 : sort)
    APIProvider.shared.foodAPI.rx.request(.foodList(param: param))
      .filterSuccessfulStatusCodes()
      .map(FoodListResponse.self)
      .subscribe(onSuccess: { value in
        self.initAdvertisementList(foodList: value.list)
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initAdvertisementList(foodList: [FoodListData]) {
    let param = AdvertisementListRequest(location: .광고리스트, category: .반찬공유)
    APIProvider.shared.advertisementAPI.rx.request(.list(param: param))
      .filterSuccessfulStatusCodes()
      .map(AdvertisementListResponse.self)
      .subscribe(onSuccess: { value in
        self.foodList = foodList
        
        if value.list.count > 0 {
          for i in 0..<value.list.count {
            let checkCount = ((i + 1) * 5)
            if self.foodList.indices.contains(checkCount) && self.foodList.indices.contains(checkCount + i) {
              let foodListData = FoodListData(id: 0, thumbnail: nil, category: "", name: "", price: 0, wishCount: 0, isWish: true, isLike: nil, likeCount: 0, dislikeCount: 0, statusSale: true, address: "", viewCount: 0, villageId: 0, user: nil, commentCount: 0, status: .조리예정, userCount: nil, dueDate: nil, requestCount: 0, isRequest: true, hashtag: [], isReport: true, advertisementData: value.list[i])
              self.foodList.insert(foodListData, at: checkCount + i)
              print("checkCount + (i): \(checkCount + (i))")
            }
          }
        }
        
        self.foodListCollectionView.reloadData()
        self.dismissHUD()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  // FoodCategoryReusableViewDelegate
  func setCategory(category: FoodCategory) {
    self.category = category
    initFoodList()
  }
  
  func bindInput() {
    filterButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = FoodSortPopupVC.viewController()
        vc.delegate = self
        self.present(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    searchButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = SearchFoodAndUsedVC.viewController()
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
}

extension FoodVC: FoodSortDelegate {
  func setFoodSort(sort: FoodSort) {
    initFoodList(sort: sort)
  }
}

extension FoodVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      let headerView = foodListCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! FoodCategoryReusableView
      headerView.delegate = self
      headerView.selectedCategory = category
      headerView.collectionView.reloadData()
      return headerView
    default:
      return UICollectionReusableView()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return foodList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = foodListCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FoodListCell
    let dict = foodList[indexPath.row]
    if dict.advertisementData == nil {
      cell.update(dict)
    } else {
      cell.updateWithAdvertisementData(dict.advertisementData!)
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let dict = foodList[indexPath.row]
    if dict.advertisementData == nil {
      let vc = FoodDetailVC.viewController()
      vc.foodId = dict.id
      self.navigationController?.pushViewController(vc, animated: true)
    } else {
      if let advertisement = dict.advertisementData {
        if advertisement.diff == "url" {
          if let openUrl = URL(string: advertisement.url!) {
            UIApplication.shared.open(openUrl, options: [:])
          }
        } else {
          let vc = AdvertisementDetailVC.viewController()
          vc.images = [Image(id: 0, name: advertisement.image ?? "")]
          navigationController?.pushViewController(vc, animated: true)
        }
      }
    }
  }
}
