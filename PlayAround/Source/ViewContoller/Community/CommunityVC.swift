//
//  CommunityVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/25.
//

import Foundation
import UIKit

class CommunityVC: BaseViewController, CommunityCategoryReusableViewDelegate, CommunitySortDelegate {
  
  func setCommunitySort(sort: CommunitySort) {
    selectFilter = sort
    initCommunityList()
  }
  
  
  @IBOutlet weak var communityListCollectionView: UICollectionView!
  @IBOutlet weak var filterButton: UIButton!
  @IBOutlet weak var villageButton: UIButton!
  @IBOutlet weak var writCommunityImageView: UIImageView!
  
  
  var selectFilter: CommunitySort = .최신순
  var category: CommunityCategory = .전체
  var communityList: [CommuintyList] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    villageButton.setTitle(DataHelperTool.villageName, for: .normal)
    setCollectionView()
    setCommunityListCollectionViewLayout()
    rxtap()
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
    layout.itemSize = CGSize(width: APP_WIDTH(), height: 122)
    layout.headerReferenceSize = CGSize(width: APP_WIDTH(), height: 87)
    layout.invalidateLayout()
    communityListCollectionView.collectionViewLayout = layout
  }
  
  func initCommunityList() {
    
    self.showHUD()
    let param = categoryListRequest(category: category == .전체 ? nil : category,villageId: DataHelperTool.villageId,latitude: "\(currentLocation?.0 ?? 0.0)", longitude: "\(currentLocation?.1 ?? 0.0)" , sort: selectFilter == .최신순 ? nil : selectFilter.rawValue)
    APIProvider.shared.communityAPI.rx.request(.CommuntyList(param: param))
      .filterSuccessfulStatusCodes()
      .map(CommunityResponse.self)
      .subscribe(onSuccess: { value in
        self.communityList = value.list
        self.communityListCollectionView.reloadData()
        
        print("self.communityList.count : \(self.communityList.count)")
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
  
  func rxtap(){
    filterButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = CommunitySortPopupVC.viewController()
        vc.delegate = self
        self.present(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    villageButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "VillageListVC") as! VillageListVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    writCommunityImageView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
      let vc = UIStoryboard.init(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "MyCommunityRegisterVC") as! MyCommunityRegisterVC
      self.navigationController?.pushViewController(vc, animated: true)
    })
      .disposed(by: disposeBag)
    
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

extension CommunityVC: SelectVillage{
  func select() {
    villageButton.setTitle(DataHelperTool.villageName, for: .normal)
  }
  
  
}
