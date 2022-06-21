//
//  WishListVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/20.
//

import UIKit

enum WishDiff: String, Codable {
  case food = "반찬공유"
  case used = "중고거래"
}

class WishListVC: BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var diffCollectionView: UICollectionView!
  @IBOutlet weak var wishListCollectionView: UICollectionView!
  
  let diffList: [WishDiff] = [.food, .used]
  var selectedDiff: WishDiff = .food
  
  var foodList: [FoodListData] = []
  var usedList: [UsedListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setCollectionViews()
    initList()
  }
  
  static func viewController() -> WishListVC {
    let viewController = WishListVC.viewController(storyBoardName: "Setting")
    return viewController
  }
  
  func setCollectionViews() {
    diffCollectionView.delegate = self
    diffCollectionView.dataSource = self
    
    wishListCollectionView.delegate = self
    wishListCollectionView.dataSource = self
    
    diffCollectionView.reloadData()
  }
  
  func initList() {
    if selectedDiff == .food {
      initFoodList()
    } else {
      initUsedList()
    }
  }
  
  func initFoodList() {
    let param = FoodListRequest(isWish: true)
    APIProvider.shared.foodAPI.rx.request(.foodList(param: param))
      .filterSuccessfulStatusCodes()
      .map(FoodListResponse.self)
      .subscribe(onSuccess: { value in
        self.foodList = value.list
        self.wishListCollectionView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initUsedList() {
    let param = UsedListRequest()
    APIProvider.shared.usedAPI.rx.request(.list(param: param))
      .filterSuccessfulStatusCodes()
      .map(UsedListResponse.self)
      .subscribe(onSuccess: { value in
        self.usedList = value.list
        self.wishListCollectionView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
}
extension WishListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if diffCollectionView == collectionView {
      return diffList.count
    } else {
      return selectedDiff == .food ? foodList.count : usedList.count
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
      let cell = wishListCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FoodListCell
      
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
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if diffCollectionView == collectionView {
      let dict = diffList[indexPath.row]
      
      selectedDiff = dict
      diffCollectionView.reloadData()
      initList()
    } else {
      if selectedDiff == .food {
        let dict = foodList[indexPath.row]
        let vc = FoodDetailVC.viewController()
        vc.foodId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      } else {
        let dict = usedList[indexPath.row]
        let vc = UsedDetailVC.viewController()
        vc.usedId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if diffCollectionView == collectionView {
      let dict = diffList[indexPath.row]
      let width = textWidth(text: dict.rawValue, font: .systemFont(ofSize: 12, weight: .medium)) + 18

      return CGSize(width: width, height: 30)
    } else {
      let foodCellSize = CGSize(width: (APP_WIDTH() - 40) / 2, height: 195)
      let usedCellSize = CGSize(width: (APP_WIDTH() - 40) / 2, height: 175)
      
      return selectedDiff == .food ? foodCellSize : usedCellSize
    }
  }
}
