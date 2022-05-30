//
//  CommunityVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/25.
//

import Foundation
import UIKit

class CommunityVC: BaseViewController, CommunityCategoryReusableViewDelegate {
  
  @IBOutlet weak var communityListCollectionView: UICollectionView!
  
  var category: CommunityCategory = .전체
  var communityList: [commuintyList] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setCollectionView()
    setCommunityListCollectionViewLayout()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
    initCommunityList()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
  }
  
  func setCollectionView() {
    communityListCollectionView.dataSource = self
    communityListCollectionView.delegate = self
    communityListCollectionView.register(UINib(nibName: "CommunityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Community")
  }
  
  func setCommunityListCollectionViewLayout() {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: APP_WIDTH(), height: 120)
    layout.headerReferenceSize = CGSize(width: APP_WIDTH(), height: 87)
    layout.invalidateLayout()
    communityListCollectionView.collectionViewLayout = layout
  }
  
  func initCommunityList() {
    self.showHUD()
    let param = categoryListRequest(category: category == .전체 ? nil : category)
    APIProvider.shared.communityAPI.rx.request(.CommuntyList(param: param))
      .filterSuccessfulStatusCodes()
      .map(CommunityResponse.self)
      .subscribe(onSuccess: { value in
        self.communityList = value.list
        self.communityListCollectionView.reloadData()
        
        print("self.foodList.count : \(self.communityList.count)")
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  
  // FoodCategoryReusableViewDelegate
  func setCategory(category: CommunityCategory) {
    self.category = category
    initCommunityList()
  }
  
}

extension CommunityVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      let headerView = communityListCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CommunityCategoryReusableView
      headerView.delegate = self
      headerView.selectedCategory = category
      headerView.collectionView.reloadData()
      return headerView
    default:
      return UICollectionReusableView()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return communityList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = communityListCollectionView.dequeueReusableCell(withReuseIdentifier: "Community", for: indexPath) as! CommunityCollectionViewCell
    let dict = communityList[indexPath.row]
    cell.update(dict)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let dict = communityList[indexPath.row]
    let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityDetailVC") as! CommunityDetailVC
    vc.communityId = dict.id
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
