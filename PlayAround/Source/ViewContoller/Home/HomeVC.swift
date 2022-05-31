//
//  HomeVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/16.
//

import Foundation
import UIKit

class HomeVC: BaseViewController{
  @IBOutlet weak var headerCollectionView: UICollectionView!
  @IBOutlet weak var advertisementCollectionView: UICollectionView!
  @IBOutlet weak var productCollectionview: UICollectionView!
  @IBOutlet weak var mainTableVIew: UITableView!
  
  var headerList: [CommuintyList] = []
  var adList: [AdvertiseList] = []
  var usedList : [UsedList] = []
  var foodList : [FoodList] = []
  
  override func viewDidLoad() {
    initDelegate()
    navigationController?.isNavigationBarHidden = true
    
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.itemSize = CGSize(width: 358, height: 128.0)
    flowLayout.minimumLineSpacing = 0
    headerCollectionView.collectionViewLayout = flowLayout
    
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
    initFoodList()
    initUsedList()
  }
  
  func initHeaderList() {
    self.showHUD()
    let param = categoryListRequest(myList: true)
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
  
  func initAdvList() {
    self.showHUD()
    APIProvider.shared.authAPI.rx.request(.advertisement(location: "메인배너"))
      .filterSuccessfulStatusCodes()
      .map(AdvertiseResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 202){
          self.adList = value.list
          print("\(self.adList.count)!!!")
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
    APIProvider.shared.usedAPI.rx.request(.UsedList(param: param))
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
    let param = FoodListRequest()
    APIProvider.shared.foodAPI.rx.request(.foodList(param: param))
      .filterSuccessfulStatusCodes()
      .map(FoodResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 202){
          self.foodList = value.list
          print("\(self.foodList.count)!!!")
          self.advertisementCollectionView.reloadData()
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if(collectionView == self.headerCollectionView){
      return headerList.count
    }else if(collectionView == self.advertisementCollectionView){
      return adList.count
    }else {
      return usedList.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if(collectionView == self.headerCollectionView){
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
      let dict = headerList[indexPath.row]
      
      if(!dict.images.isEmpty){
        cell.thumbnail.kf.setImage(with: URL(string: dict.images[0].name))
      } else {
        cell.thumbnail.image = nil
      }
      
      cell.category.text = dict.category
      cell.Title.text = dict.name
      cell.content.text = dict.content
      cell.distance.text = "\(dict.distance)"
      cell.watchPeople.text = "\(dict.people)"
      cell.LikeCount.text = "좋아요 \(dict.likeCount)"
      cell.DisLikeCount.text = "싫어요 \(dict.dislikeCount)"
      
      cell.backView?.cornerRadius  = 10
      cell.backView?.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117, alpha: 1.0), alpha: 1, x: 0, y: 3, blur: 10, spread: 0)
      
      return cell
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
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if(collectionView == headerCollectionView){
      return CGSize(width: 358, height : 128)
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
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let cell = self.mainTableVIew.dequeueReusableCell(withIdentifier: "MainFooterCell") as! MainFooterCell
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 90
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 61
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return usedList.count
    return 5
  }
  //
  //      func scrollViewDidScroll(_ scrollView: UIScrollView) {
  //                        if scrollView.contentOffset.y > 10 {
  //                          HomeVC?.navigationhidden(true)
  //                        }else{
  //                          HomeVC?.navigationhidden(false)
  //                        }
  //
  //      }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = self.mainTableVIew.dequeueReusableCell(withIdentifier: "TableView2Cell", for: indexPath) as! TableView2Cell
    let cell = self.mainTableVIew.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
//    let dict = usedList[indexPath.row]
//    cell.initdelegate(dict)
    
    cell.selectionStyle = .none
    
    return cell
    
  }
  
  //  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  //    let dict = FoodList[indexPath.row]
  //
  //    let vc = UIStoryboard.init(name: "home", bundle: nil).instantiateViewController(withIdentifier: "HomeDetail") as! HomeDetailVC
  //    vc.DetailTitle = dict.category
  //    vc.id = dict.id
  //    self.navigationController?.pushViewController(vc, animated: true)
  //
  //  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 150
  }
  
}
