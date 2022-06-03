//
//  FoodVC.swift
//  PlayAround
//
//  Created by haon on 2022/05/23.
//

import UIKit

class FoodVC: BaseViewController, FoodCategoryReusableViewDelegate {
  
  @IBOutlet weak var foodListCollectionView: UICollectionView!
  
  var category: FoodCategory = .전체
  var foodList: [FoodListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setFoodListCollectionViewLayout()
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
  
  func initFoodList() {
    self.showHUD()
    let param = FoodListRequest(category: category == .전체 ? nil : category)
    APIProvider.shared.foodAPI.rx.request(.foodList(param: param))
      .filterSuccessfulStatusCodes()
      .map(FoodListResponse.self)
      .subscribe(onSuccess: { value in
        self.foodList = value.list
        self.foodListCollectionView.reloadData()
        
        print("self.foodList.count : \(self.foodList.count)")
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  
  // FoodCategoryReusableViewDelegate
  func setCategory(category: FoodCategory) {
    self.category = category
    initFoodList()
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
    cell.update(dict)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let dict = foodList[indexPath.row]
    let vc = FoodDetailVC.viewController()
    vc.foodId = dict.id
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
