//
//  UsedVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/15.
//

import UIKit

class UsedVC: BaseViewController, UsedCategoryReusableViewDelegate {
  
  @IBOutlet weak var filterButton: UIButton!
  @IBOutlet weak var usedListCollectionView: UICollectionView!
  
  var category: UsedCategory = .전체
  var usedList: [UsedListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUsedListCollectionViewLayout()
    bindInput()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
    initUsedList()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
  }
  
  func setUsedListCollectionViewLayout() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    layout.itemSize = CGSize(width: (APP_WIDTH() - 40) / 2, height: 195)
    layout.minimumInteritemSpacing = 10
    layout.minimumLineSpacing = 10
    layout.headerReferenceSize = CGSize(width: APP_WIDTH(), height: 87)
    layout.invalidateLayout()
    usedListCollectionView.collectionViewLayout = layout
  }
  
  // UsedCategoryReusableViewDelegate
  func setCategory(category: UsedCategory) {
    self.category = category
    initUsedList()
  }
  
  func initUsedList(sort: UsedSort? = nil) {
    self.showHUD()
    let param = UsedListRequest(category: category == .전체 ? nil : category, sort: sort == nil ? .최신순 : sort)
    APIProvider.shared.usedAPI.rx.request(.list(param: param))
      .filterSuccessfulStatusCodes()
      .map(UsedListResponse.self)
      .subscribe(onSuccess: { value in
        self.usedList = value.list
        self.usedListCollectionView.reloadData()
        
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func bindInput() {
    filterButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
//        let vc = FoodSortPopupVC.viewController()
//        vc.delegate = self
//        self.present(vc, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
}
extension UsedVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      let headerView = usedListCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! UsedCategoryReusableView
      headerView.delegate = self
      headerView.selectedCategory = category
      headerView.collectionView.reloadData()
      return headerView
    default:
      return UICollectionReusableView()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return usedList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = usedListCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FoodListCell
    let dict = usedList[indexPath.row]
    cell.update(dict)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let dict = usedList[indexPath.row]
    let vc = UsedDetailVC.viewController()
    vc.usedId = dict.id
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
