//
//  CommunityDetailVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/30.
//

import Foundation
import UIKit
import XLPagerTabStrip
enum Category: String, Codable {
  case 공지사항
  case 자유게시판
  case 채팅방
}
class CommunityDetailVC: BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var mainTableView: UITableView!
  @IBOutlet weak var imageCollectionView: UICollectionView!
  @IBOutlet weak var categoryCollectionView: UICollectionView!
  
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var distanToMeLabel: UILabel!
  @IBOutlet weak var peopleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var likeImageVIew: UIImageView!
  @IBOutlet weak var dislikeImageView: UIImageView!
  @IBOutlet weak var likeCountLabel: UILabel!
  @IBOutlet weak var disLikeLabel: UILabel!
  
  var communityId: Int = 0
  var imageList: [Image] = []
  
  var communityBoard: [CommunityBoard] = []
  var communityNotice: [CommunityNotice] = []
  
  var selectedCategory = "공지사항"
  var category: [Category] = [.공지사항, .자유게시판, .채팅방]
  
  override func viewDidLoad() {
    initDelegate()
    
    initDetail()
    
    initDetailNotice(communityId)
  }
  
  static func viewController() -> CommunityDetailVC {
    let viewController = CommunityDetailVC.viewController(storyBoardName: "Community")
    return viewController
  }
  
  func initDelegate(){
    mainTableView.dataSource = self
    mainTableView.delegate = self
    imageCollectionView.dataSource = self
    imageCollectionView.delegate = self
    categoryCollectionView.dataSource = self
    categoryCollectionView.delegate = self
    

    imageCollectionView.register(UINib(nibName: "CollectionViewImageCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewImageCell")
  }
  
  func initDetail() {
    self.showHUD()
    APIProvider.shared.communityAPI.rx.request(.CommuntyDetail(id: communityId))
      .filterSuccessfulStatusCodes()
      .map(CommuintyDetailResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          self.setData(value.data)
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initDetailNotice(_ communityId: Int){
    self.showHUD()
    let param = ComunityNoticeRequest(communityId: communityId)
    APIProvider.shared.communityAPI.rx.request(.CommuntyNotice(param: param))
      .filterSuccessfulStatusCodes()
      .map(CommunityNoticeResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          self.communityNotice = value.list ?? []
          self.mainTableView.reloadData()
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initDetailBoard(_ communityId: Int){
    self.showHUD()
    let param = ComunityNoticeRequest(communityId: communityId)
    APIProvider.shared.communityAPI.rx.request(.CommuntyBoard(param: param))
      .filterSuccessfulStatusCodes()
      .map(CommunityBoardResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          self.communityBoard = value.list ?? []
          self.mainTableView.reloadData()
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func setData(_ data: CommunityDetail){
    self.categoryLabel.text = data.category
    self.titleLabel.text = data.name
    self.contentLabel.text = data.content
    self.nameLabel.text = data.userName
    self.distanToMeLabel.text = "나와의 거리 \(data.distance)KM"
    self.peopleLabel.text = "참여인원 \(data.people)명"
    self.likeCountLabel.text = "\(data.likeCount)"
    self.disLikeLabel.text = "\(data.dislikeCount)"
    
    imageList = data.images
    imageCollectionView.reloadData()
  }
  
  @IBAction func tapRegister(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityDetailRegisterVC") as! CommunityDetailRegisterVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
}

extension CommunityDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if (collectionView == imageCollectionView) {
      return imageList.count
    } else{
      return category.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if(collectionView == imageCollectionView){
      let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewImageCell", for: indexPath) as! CollectionViewImageCell
      let dict = imageList[indexPath.row]
      cell.setImage(dict)
      return cell
    }else {
      let cell = self.categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "DetailTapCell", for: indexPath)
      let dict = category[indexPath.row]
      guard let diffLabel = cell.viewWithTag(1) as? UILabel,
            let selectedView = cell.viewWithTag(2)else {
              return cell
            }
      diffLabel.text = dict.rawValue
      selectedView.isHidden = selectedCategory != dict.rawValue
      if (selectedCategory == "공지사항") {
        initDetailNotice(communityId)
      }else if selectedCategory == "자유게시판" {
        initDetailBoard(communityId)
      }else{
        initDetailBoard(communityId)
      }
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if(collectionView == imageCollectionView){
      return CGSize(width: APP_WIDTH(), height: 225)
    }else{
      return CGSize(width: (APP_WIDTH()-10)/3, height: 35)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if(collectionView == imageCollectionView){
      let dict = imageList[indexPath.row]
    }else{
      let dict = category[indexPath.row]
      selectedCategory = dict.rawValue
      categoryCollectionView.reloadData()
    }
  }
}
extension CommunityDetailVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if selectedCategory == "공지사항"{
      return communityNotice.count
    }else if selectedCategory == "자유게시판"{
      return communityBoard.count
    }else{
      return communityBoard.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if selectedCategory == "공지사항"{
      let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath)
      
      let dict = communityNotice[indexPath.row]
      guard let titleLabel = cell.viewWithTag(1) as? UILabel,
            let contentLabel = cell.viewWithTag(2) as? UILabel,
            let likeLabel = cell.viewWithTag(3) as? UILabel,
            let dislikeLabel = cell.viewWithTag(4) as? UILabel,
            let dateLabel = cell.viewWithTag(5) as? UILabel else {
              return cell
            }
      titleLabel.text = dict.title
      contentLabel.text = dict.content
      likeLabel.text = "좋아요 \(dict.likeCount)"
      likeLabel.text = "싫어요 \(dict.dislikeCount)"
      dateLabel.text = dict.createdAt
      
      return cell
    }else if selectedCategory == "자유게시판"{
      let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath)
      
      let dict = communityBoard[indexPath.row]
      guard let titleLabel = cell.viewWithTag(1) as? UILabel,
            let contentLabel = cell.viewWithTag(2) as? UILabel,
            let likeLabel = cell.viewWithTag(3) as? UILabel,
            let dislikeLabel = cell.viewWithTag(4) as? UILabel,
            let dateLabel = cell.viewWithTag(5) as? UILabel else {
              return cell
            }
      titleLabel.text = dict.title
      contentLabel.text = dict.content
      likeLabel.text = "좋아요 \(dict.likeCount)"
      likeLabel.text = "싫어요 \(dict.dislikeCount)"
      dateLabel.text = dict.createdAt
      
      return cell
    }else{
      let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "chattingCell", for: indexPath)
      guard let thumbnail = cell.viewWithTag(1) as? UIImageView,
            let titleLabel = cell.viewWithTag(2) as? UILabel,
            let peopleLabel = cell.viewWithTag(3) as? UILabel,
            let dateLabel = cell.viewWithTag(4) as? UILabel,
            let contentLabel = cell.viewWithTag(5) as? UILabel else {
              return cell
            }
      
      return cell
    }
  }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if selectedCategory == "공지사항"{
        let dict = communityNotice[indexPath.row]
        let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityInfoDetailVC") as! CommunityInfoDetailVC
        vc.naviTitle = selectedCategory
        vc.detailId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      }else if selectedCategory == "자유게시판"{
        let dict = communityBoard[indexPath.row]
        let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityInfoDetailVC") as! CommunityInfoDetailVC
        vc.naviTitle = selectedCategory
        vc.detailId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      }else{
        let dict = communityBoard[indexPath.row]
      }
    }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if selectedCategory == "공지사항"{
      return 90
    }else if selectedCategory == "자유게시판"{
      return 90
    }else{
      return 100
    }
  }
  
}

