//
//  HomeVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/16.
//

import Foundation
import UIKit
import Gifu

class HomeVC: BaseViewController{
  @IBOutlet weak var headerCollectionView: UICollectionView!
  @IBOutlet weak var advertisementCollectionView: UICollectionView!
  @IBOutlet weak var productCollectionview: UICollectionView!
  @IBOutlet weak var mainTableVIew: UITableView!
  @IBOutlet weak var villageButton: UIButton!
  @IBOutlet weak var homeSplash: GIFImageView!
  
  @IBOutlet weak var initAdHeight: NSLayoutConstraint!
  
  var headerList: [CommuintyList] = []
  var communityList: [CommuintyList] = []
  var adList: [AdvertiseList] = []
  var usedList : [UsedList] = []
  var foodList : [FoodListData] = []
  
  override func viewDidLoad() {
    
    villageButton.setTitle(DataHelperTool.villageName, for: .normal)
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.itemSize = CGSize(width: 358, height: 128.0)
    flowLayout.minimumLineSpacing = 0
    headerCollectionView.collectionViewLayout = flowLayout
    self.homeSplash.animate(withGIFNamed: "home")
    //    communityListCollectionView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellWithReuseIdentifier: "TableViewCell")
    
  }
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = true
    initDelegate()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
  }
  
  func initDelegate(){
    headerCollectionView.delegate = self
    advertisementCollectionView.delegate = self
    productCollectionview.delegate = self
    mainTableVIew.delegate = self
    
    headerCollectionView.dataSource = self
    advertisementCollectionView.dataSource = self
    productCollectionview.dataSource = self
    mainTableVIew.dataSource = self
    
    headerCollectionView.backgroundColor = .clear
    headerCollectionView.decelerationRate = .fast
    headerCollectionView.isPagingEnabled = false
    
    initHeaderList()
    initAdvList()
    initCommunityList()
    initFoodList()
    initUsedList()
    rxtap()
  }
  
  func initHeaderList() {
    self.showHUD()
    let param = categoryListRequest(myList: "true",dong: DataHelperTool.villageName)
    APIProvider.shared.communityAPI.rx.request(.CommuntyList(param:param))
      .filterSuccessfulStatusCodes()
      .map(CommunityResponse.self)
      .subscribe(onSuccess: { value in
        
        if(value.statusCode <= 202){
          self.headerList = value.list
          print("\(self.headerList.count)!!!")
          self.headerCollectionView.reloadData()
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  func initCommunityList() {
    self.showHUD()
    let param = categoryListRequest(page:1,limit:5,dong: DataHelperTool.villageName ,latitude: "\(currentLocation?.0 ?? 0.0)", longitude: "\(currentLocation?.1 ?? 0.0)")
    APIProvider.shared.communityAPI.rx.request(.CommuntyList(param:param))
      .filterSuccessfulStatusCodes()
      .map(CommunityRowResponse.self)
      .subscribe(onSuccess: { value in
        
        if(value.statusCode <= 202){
          self.communityList = value.list.rows
          print("communityList: !!!")
          self.mainTableVIew.reloadData()
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initAdvList() {
    self.showHUD()
    APIProvider.shared.authAPI.rx.request(.advertisement(location: "메인배너"))
      .filterSuccessfulStatusCodes()
      .map(AdvertiseResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 202){
          print("\(self.adList.count)!!!")
          self.adList = value.list
          
          self.initAdHeight.constant = self.adList.isEmpty ? 0 : 128
          
          self.mainTableVIew.layoutTableHeaderView()
          
          self.advertisementCollectionView.reloadData()
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initUsedList() {
    self.showHUD()
    let param = UsedListRequest()
    APIProvider.shared.usedAPI.rx.request(.list(param: param))
      .filterSuccessfulStatusCodes()
      .map(UsedResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 202){
          self.usedList = value.list
          print("\(self.usedList.count)!!!")
          self.productCollectionview.reloadData()
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initFoodList() {
    self.showHUD()
    let param = FoodListRequest(page:1, limit: 4)
    APIProvider.shared.foodAPI.rx.request(.foodList(param: param))
      .filterSuccessfulStatusCodes()
      .map(FoodRowResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 202){
          self.foodList = value.list.rows
          print("food]List: !!!")
          self.mainTableVIew.reloadData()
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  func rxtap(){
    
    villageButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "VillageListVC") as! VillageListVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
  }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if(collectionView == self.headerCollectionView){
      if headerList.count == 0 {
        return 1
      }else{
        return headerList.count
      }
    }else if(collectionView == self.advertisementCollectionView){
      return adList.count
    }else {
      return usedList.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if(collectionView == self.headerCollectionView){
      if headerList.count == 0 {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
        cell.emptyView.isHidden = false
        cell.backView.isHidden = true
        cell.emptyView?.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 0, y: 1.5, blur: 5, spread: 0)
        cell.emptyView?.layer.cornerRadius  = 10
        
        return cell
      }else{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
        let dict = headerList[indexPath.row]
        
        if(!dict.images.isEmpty){
          cell.thumbnail.kf.setImage(with: URL(string: dict.images[0].name))
        }
        
        cell.category.text = dict.category
        cell.Title.text = dict.name
        cell.content.text = dict.content
        cell.distance.text = "\(dict.distance)"
        cell.watchPeople.text = "\(dict.people)"
        cell.LikeCount.text = "좋아요 \(dict.likeCount)"
        cell.DisLikeCount.text = "싫어요 \(dict.dislikeCount)"
        
        cell.emptyView.isHidden = true
        cell.backView.isHidden = false
//        cell.backView?.borderWidth = 1
//        cell.backView.borderColor = .lightGray
        cell.backView?.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 0, y: 1.5, blur: 5, spread: 0)
        cell.backView?.layer.cornerRadius  = 10
        
        return cell
      }
    }else if(collectionView == self.advertisementCollectionView){
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdvertisementCell", for: indexPath) as! AdvertisementCell
      let dict = adList[indexPath.row]
      if(dict.thumbnail != nil){
        cell.banner?.kf.setImage(with: URL(string: dict.thumbnail!))
      }
      return cell
    }else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsedCell", for: indexPath) as! UsedCell
      let dict = usedList[indexPath.row]
      
      //      if(dict!.thumbnail != nil){
      //        cell.Thumbnail?.kf.setImage(with: URL(string: dict!.thumbnail))
      //      }
      cell.initdelegate(dict)
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if(collectionView == self.headerCollectionView){
      if headerList.count != 0 {
        let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityDetailVC") as! CommunityDetailVC
        vc.communityId = headerList[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if(collectionView == headerCollectionView){
      if headerList.count == 0 || headerList.count == 1{
        return CGSize(width: APP_WIDTH(), height : 148)
      }else{
        return CGSize(width: 358, height : 148)
      }
    }else if(collectionView == advertisementCollectionView){
      return CGSize(width: self.advertisementCollectionView.frame.size.width , height: self.headerCollectionView.frame.height)
    }else {
      return CGSize(width: 160, height: self.productCollectionview.frame.height)
    }
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if(scrollView.isEqual(self.headerCollectionView)){
      guard let layout = self.headerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
      
      // CollectionView Item Size
      let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
      
      // 이동한 x좌표 값과 item의 크기를 비교 후 페이징 값 설정
      let estimatedIndex = scrollView.contentOffset.x / cellWidthIncludingSpacing
      let index: Int
      
      // 스크롤 방향 체크
      // item 절반 사이즈 만큼 스크롤로 판단하여 올림, 내림 처리
      if velocity.x > 0 {
        index = Int(ceil(estimatedIndex))
      } else if velocity.x < 0 {
        index = Int(floor(estimatedIndex))
      } else {
        index = Int(round(estimatedIndex))
      }
      // 위 코드를 통해 페이징 될 좌표 값을 targetContentOffset에 대입
      targetContentOffset.pointee = CGPoint(x: CGFloat(index) * cellWidthIncludingSpacing, y: 0)
    }
  }
}
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = self.mainTableVIew.dequeueReusableCell(withIdentifier: "MainHeaderCell") as! MainHeaderCell
    if section == 0{
      cell.initHedaer("커뮤니티")
    }else{
      cell.initHedaer("반찬")
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.mainTableVIew.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as! HomeContentCell
    if indexPath.section == 0{
      cell.initCommunity(communityList)
      cell.HomeVc = self
    }else {
      cell.initFood(foodList)
      cell.HomeVc = self
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let cell = self.mainTableVIew.dequeueReusableCell(withIdentifier: "MainFooterCell") as! MainFooterCell
    cell.initCell()
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 79
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 83
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
    }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0{
      return CGFloat(122 * communityList.count)
    } else {
      let height = ((APP_WIDTH() - 40) / 2) / 142 * 100 + 87
      let size : Int = Int(height) * (foodList.count / 2 + (foodList.count % 2))
      return CGFloat(size)
    }
  }
}

extension HomeVC: SelectVillage{
  func select() {
    villageButton.setTitle(DataHelperTool.villageName, for: .normal)
    initHeaderList()
  }
}

