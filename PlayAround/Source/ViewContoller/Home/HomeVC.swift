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
  @IBOutlet weak var mainScrollView: UIScrollView!
  
  @IBOutlet weak var headerCollectionView: UICollectionView!
  @IBOutlet weak var advertisementCollectionView: UICollectionView!
  @IBOutlet weak var communityCollectionview: UICollectionView!
  @IBOutlet weak var foodCollectionview: UICollectionView!
  @IBOutlet weak var productCollectionview: UICollectionView!
  
  @IBOutlet weak var communityBackView: UIView!
  @IBOutlet weak var foodBackView: UIView!
  
  @IBOutlet weak var communityStackView: UIView!
  @IBOutlet weak var foodStackView: UIView!
  
  @IBOutlet weak var villageButton: UILabel!
  @IBOutlet weak var CommunityMoreButton: UIButton!
  @IBOutlet weak var foodMoreButton: UIButton!
  @IBOutlet weak var homeGifImage: GIFImageView!
  
  @IBOutlet weak var communityCollectionHeight: NSLayoutConstraint!
  @IBOutlet weak var foodCollectionHeight: NSLayoutConstraint!
  
  let refreshControl = UIRefreshControl()
  var usedList : [UsedList] = []{
    didSet{
      productCollectionview.reloadData()
    }
  }
  var adList: [AdvertiseList] = []{
    didSet{
      if adList.isEmpty{
        advertisementCollectionView.isHidden = true
      }else{
        advertisementCollectionView.isHidden = false
        advertisementCollectionView.reloadData()
      }
    }
  }
  var headerList: [CommuintyList] = []{
    didSet{
      headerCollectionView.reloadData()
    }
  }
  var communityList: [CommuintyList] = []{
    didSet{
      if communityList.isEmpty{
        communityStackView.isHidden = true
      }else{
        communityStackView.isHidden = false
        communityCollectionHeight.constant = CGFloat(communityList.count * 112)
        communityCollectionview.reloadData()
      }
    }
  }
  var foodList : [FoodListData] = []{
    didSet{
      if foodList.isEmpty{
          foodStackView.isHidden = true
        }else{
          foodStackView.isHidden = false
          let height = ((APP_WIDTH() - 40) / 2) / 142 * 100 + 65
          foodCollectionHeight.constant = height * CGFloat((foodList.count / 2 + (foodList.count % 2)))
          foodCollectionview.reloadData()
        }
    }
  }
  var currentIndex: CGFloat = 0
  
  override func viewWillAppear(_ animated: Bool) {
    villageButton.text = DataHelperTool.villageName
    print("!!")
    initDelegate()
    navigationController?.isNavigationBarHidden = true
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    
  }
  
  override func viewDidLoad() {
    rxtap() 
    shadow(backView: communityBackView)
    shadow(backView: foodBackView)
  }
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
  }
  
  func shadow(backView: UIView){
    backView.layer.masksToBounds = false
    backView.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 1.5, y: 1.5, blur: 10, spread: 0)
  }
  
  func initDelegate(){
    refreshControl.endRefreshing()
    mainScrollView.refreshControl = refreshControl
    
    headerCollectionView.delegate = self
    advertisementCollectionView.delegate = self
    communityCollectionview.delegate = self
    foodCollectionview.delegate = self
    productCollectionview.delegate = self
    
    headerCollectionView.dataSource = self
    advertisementCollectionView.dataSource = self
    communityCollectionview.dataSource = self
    foodCollectionview.dataSource = self
    productCollectionview.dataSource = self
    
    headerCollectionView.backgroundColor = .clear
    headerCollectionView.decelerationRate = .fast
    headerCollectionView.isPagingEnabled = false
    
    userInfo { value in
      self.initHeaderList(id: value.data.id)
    }
    self.initAdvList()
    self.initCommunityList()
    self.initFoodList()
    self.initUsedList()
  }
  
  func initHeaderList(id: Int) {
    let param = categoryListRequest(villageId: DataHelperTool.villageId, userId: id)
    APIProvider.shared.communityAPI.rx.request(.CommuntyList(param:param))
      .filterSuccessfulStatusCodes()
      .map(CommunityResponse.self)
      .subscribe(onSuccess: { value in
        
        if(value.statusCode <= 202){
          self.headerList.removeAll()
          self.headerList = value.list
        }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initAdvList() {
    APIProvider.shared.authAPI.rx.request(.advertisement(location: "메인배너"))
      .filterSuccessfulStatusCodes()
      .map(AdvertiseResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 202){
          self.adList.removeAll()
          self.adList = value.list
        }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initCommunityList() {
    let param = categoryListRequest(page:1,limit:4,villageId: DataHelperTool.villageId,latitude: "\(currentLocation?.0 ?? 0.0)" ,longitude: "\(currentLocation?.1 ?? 0.0)", sort: nil)
    APIProvider.shared.communityAPI.rx.request(.CommuntyList(param:param))
      .filterSuccessfulStatusCodes()
      .map(CommunityRowResponse.self)
      .subscribe(onSuccess: { value in
        
        if(value.statusCode <= 202){
          self.communityList.removeAll()
          self.communityList = value.list.rows
        }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initFoodList() {
    let param = FoodListRequest(page:1, limit: 4,villageId: DataHelperTool.villageId,sort: nil)
    APIProvider.shared.foodAPI.rx.request(.foodList(param: param))
      .filterSuccessfulStatusCodes()
      .map(FoodRowResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 202){
          self.foodList.removeAll()
          self.foodList = value.list.rows
        }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initUsedList() {
    let param = UsedListRequest(villageId: DataHelperTool.villageId,sort: nil)
    APIProvider.shared.usedAPI.rx.request(.list(param: param))
      .filterSuccessfulStatusCodes()
      .map(UsedResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 202){
          self.usedList.removeAll()
          self.usedList = value.list
        }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func rxtap(){
    
    villageButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "VillageListVC") as! VillageListVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    CommunityMoreButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.tabBarController?.selectedIndex = 1
      })
      .disposed(by: disposeBag)
    foodMoreButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.tabBarController?.selectedIndex = 2
      })
      .disposed(by: disposeBag)
    
    refreshControl.rx.controlEvent(.valueChanged)
        .bind(onNext: { [weak self] _ in
          guard let self = self else { return }
            // 아래코드: viewModel에서 발생한다고 가정
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) { [weak self] in
              self?.userInfo { value in
                self?.initHeaderList(id: value.data.id)
              }
              self?.initAdvList()
              self?.initCommunityList()
              self?.initFoodList()
              self?.initUsedList()
              self?.refreshControl.endRefreshing()
//                self?.refreshLoading.accept(true) // viewModel에서 dataSource업데이트 끝난 경우
            }
        }).disposed(by: disposeBag)
    
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
    }else if(collectionView == self.communityCollectionview){
      return communityList.count
    }else if(collectionView == self.foodCollectionview){
      return foodList.count
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
    }else if(collectionView == self.communityCollectionview){
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Community", for: indexPath)
      let dict = communityList[indexPath.row]
      guard let thumbnail = cell.viewWithTag(1) as? UIImageView,
            let tiltleLabel = cell.viewWithTag(2) as? UILabel,
            let contentLabel = cell.viewWithTag(3) as? UILabel,
            let distanceLabel = cell.viewWithTag(4) as? UILabel,
            let peopleLabel = cell.viewWithTag(5) as? UILabel,
            let likeLabel = cell.viewWithTag(6) as? UILabel,
            let disLikeLabel = cell.viewWithTag(7) as? UILabel,
            let categoryLabel = cell.viewWithTag(8) as? UILabel else {
        return cell
      }
      //          secretView.isHidden = !data.isSecret
      if(dict.images.count != 0){
        thumbnail.kf.setImage(with: URL(string: dict.images[0].name))
      }else{
        thumbnail.image = UIImage(named: "defaultBoardImage")
      }
      categoryLabel.text = dict.category
      tiltleLabel.text = dict.name
      contentLabel.text = dict.content
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      //          if let createdAtDate = dateFormatter.date(from: dict.createdAt) {
      //            self.dateLabel.text = createdAtDate.toString(dateFormat: "yyyy-MM-dd")
      //          } else {
      //            self.dateLabel.text = dict.createdAt
      //          }
      distanceLabel.text = "\(dict.distance)km"
      peopleLabel.text = "\(dict.people)명"
      likeLabel.text = "좋아요 \(dict.likeCount)"
      disLikeLabel.text = "싫어요 \(dict.dislikeCount)"
      return cell
    }else if(collectionView == self.foodCollectionview){
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Food", for: indexPath)
      let dict = foodList[indexPath.row]
      guard let thumbnail = cell.viewWithTag(1) as? UIImageView,
            let title = cell.viewWithTag(2) as? UILabel,
            let price = cell.viewWithTag(3) as? UILabel,
            let wish = cell.viewWithTag(4) as? UILabel,
            let like = cell.viewWithTag(5) as? UILabel,
            let disslike = cell.viewWithTag(6) as? UILabel,
            let complete = cell.viewWithTag(7) as? UILabel,
            let discomplete = cell.viewWithTag(8) as? UILabel else {
        return cell
      }
      //          secretView.isHidden = !data.isSecret
      if(dict.thumbnail != nil){
        thumbnail.kf.setImage(with: URL(string: dict.thumbnail ?? ""))
      }else{
        thumbnail.image = UIImage(named: "noImage")
      }
      title.text = dict.name
      price.text = "\(dict.price.formattedProductPrice() ?? "0")원"
      wish.text = "\(dict.wishCount)"
      like.text = "좋아요 \(dict.likeCount)"
      disslike.text = "싫어요 \(dict.dislikeCount)"
      if dict.status == .조리완료{
        discomplete.isHidden = true
      }else{
        complete.isHidden = true
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
        let vc = CommunityDetailVC.viewController()
        vc.communityId = headerList[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }else if collectionView == self.advertisementCollectionView{
      let dict = adList[indexPath.row]
      if dict.diff == "url" {
        if let openUrl = URL(string: dict.url!) {
          UIApplication.shared.open(openUrl, options: [:])
        }
      } else {
        let vc = AdvertisementDetailVC.viewController()
        vc.images = [Image(id: 0, name: dict.image ?? "")]
        navigationController?.pushViewController(vc, animated: true)
      }
    }else if collectionView == self.communityCollectionview{
      let dict = communityList[indexPath.row]
      let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityDetailVC") as! CommunityDetailVC
      vc.communityId = dict.id
      navigationController?.pushViewController(vc, animated: true)
    } else if collectionView == self.foodCollectionview{
      let dict = foodList[indexPath.row]
      let vc = FoodDetailVC.viewController()
      vc.foodId = dict.id
      navigationController?.pushViewController(vc, animated: true)
    } else {
      let dict = usedList[indexPath.row]
      let vc = UsedDetailVC.viewController()
      vc.usedId = dict.id
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if(collectionView == headerCollectionView){
      if headerList.count == 0 || headerList.count == 1{
        return CGSize(width: APP_WIDTH() - 30, height : 148)
      }else{
        return CGSize(width: APP_WIDTH() - 60, height : 148)
      }
    }else if(collectionView == advertisementCollectionView){
      return CGSize(width: self.advertisementCollectionView.frame.size.width , height: self.headerCollectionView.frame.height)
    }else if(collectionView == communityCollectionview){
      return CGSize(width: (APP_WIDTH() - 50), height: 102)
    }else if(collectionView == foodCollectionview){
      let imageHeight = (self.foodCollectionview.frame.width - 30) / 2
      let height = imageHeight / 142 * 100 + 65
      return CGSize(width: Int(self.foodCollectionview.frame.width - 30) / 2, height: Int(height))
    }else {
      return CGSize(width: 160, height: self.productCollectionview.frame.height)
    }
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if(scrollView.isEqual(self.headerCollectionView)){
      guard let layout = self.headerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
      let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
      
      // targetContentOff을 이용하여 x좌표가 얼마나 이동했는지 확인
      // 이동한 x좌표 값과 item의 크기를 비교하여 몇 페이징이 될 것인지 값 설정
      var offset = targetContentOffset.pointee
      let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
      var roundedIndex = round(index)
      
      // scrollView, targetContentOffset의 좌표 값으로 스크롤 방향을 알 수 있다.
      // index를 반올림하여 사용하면 item의 절반 사이즈만큼 스크롤을 해야 페이징이 된다.
      // 스크로로 방향을 체크하여 올림,내림을 사용하면 좀 더 자연스러운 페이징 효과를 낼 수 있다.
      if scrollView.contentOffset.x > targetContentOffset.pointee.x {
        roundedIndex = floor(index)
      } else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
        roundedIndex = ceil(index)
      } else {
        roundedIndex = round(index)
      }
      
      if currentIndex > roundedIndex {
        currentIndex -= 1
        roundedIndex = currentIndex
      } else if currentIndex < roundedIndex {
        currentIndex += 1
        roundedIndex = currentIndex
      }
      
      // 위 코드를 통해 페이징 될 좌표값을 targetContentOffset에 대입하면 된다.
      offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - (roundedIndex + 1) * 20 - scrollView.contentInset.left, y: -scrollView.contentInset.top)
      targetContentOffset.pointee = offset
    }
  }
}

extension HomeVC: SelectVillage{
  func select() {
    villageButton.text = DataHelperTool.villageName
  }
}

