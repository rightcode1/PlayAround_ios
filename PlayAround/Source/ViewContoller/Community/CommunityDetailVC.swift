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
class CommunityDetailVC: BaseViewController, ViewControllerFromStoryboard, CommunityDetailMenuDelegate{
  func shareCommunity() {
    
  }
  
  func updateCommunity() {
    
  }
  
  func removeCommunity() {
    
  }
  
  
  @IBOutlet weak var mainTableView: UITableView!
  @IBOutlet weak var imageCollectionView: UICollectionView!
  @IBOutlet weak var categoryCollectionView: UICollectionView!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var distanToMeLabel: UILabel!
  @IBOutlet weak var peopleLabel: UILabel!
  @IBOutlet weak var disLikeLabel: UILabel!
  @IBOutlet weak var likeCountLabel: UILabel!
  
  @IBOutlet weak var thumbnailCountLabel: UILabel!
  
  
  
  @IBOutlet weak var joinView: UIView!
  @IBOutlet weak var likeImageVIew: UIImageView!
  @IBOutlet weak var dislikeImageView: UIImageView!
  @IBOutlet weak var joinButton: UIButton!
  @IBOutlet weak var registerButton: UIImageView!
  
  var communityId: Int = 0
  var isMine : Bool = false
  var imageList: [Image] = []
  
  var communityBoard: [CommunityBoard] = []
  var communityNotice: [CommunityNotice] = []
  
  var selectedCategory = "공지사항"
  var category: [Category] = [.공지사항, .자유게시판, .채팅방]
  var authorityNotice:Bool = false
  var authorityBoard:Bool = false
  var authorityChat:Bool = false
  var authorityDelete:Bool = false
  
  override func viewDidLoad() {
    initDelegate()
    
    initDetail()
    initrx()
    
    initDetailNotice(communityId)
  }
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
  }
  
  static func viewController() -> CommunityDetailVC {
    let viewController = CommunityDetailVC.viewController(storyBoardName: "Community")
    return viewController
  }
  func initDelegate(){
    mainTableView.dataSource = self
    mainTableView.delegate = self
    mainTableView.layoutTableHeaderView()
    
    imageCollectionView.dataSource = self
    imageCollectionView.delegate = self
    categoryCollectionView.dataSource = self
    categoryCollectionView.delegate = self
    
    
    
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
  func joinBoard(_ communityId: Int){
    self.showHUD()
    let param = JoinCommunity(communityId: communityId)
    APIProvider.shared.communityAPI.rx.request(.CommuntyJoin(param: param))
      .filterSuccessfulStatusCodes()
      .map(CommunityJoinResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          self.showToast(message: "신청되었습니다.")
          self.joinButton.backgroundColor = .systemGray4
          self.joinButton.tintColor = .white
          self.joinButton.setTitle("신청중", for: .normal)
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func setData(_ data: CommunityDetail){
    self.titleLabel.text = data.name
    self.contentLabel.text = data.content
    self.nameLabel.text = data.userName
    self.distanToMeLabel.text = "나와의 거리 \(data.distance)KM"
    self.peopleLabel.text = "참여인원 \(data.people)명"
    self.likeCountLabel.text = "\(data.likeCount)"
    self.disLikeLabel.text = "\(data.dislikeCount)"
    
    authorityNotice = data.authorityNotice
    authorityBoard = data.authorityBoard
    authorityChat = data.authorityChat
    authorityDelete = data.authorityDelete
    
    imageList = data.images
    imageCollectionView.reloadData()
    if imageList.isEmpty{
      thumbnailCountLabel.isHidden = true
    }else{
      thumbnailCountLabel.isHidden = false
      thumbnailCountLabel.text = "1/\(imageList.count)"
    }
    
    if data.isJoin {
      if data.joinStatus == "대기"{
        joinView.isHidden = false
        self.joinButton.backgroundColor = .systemGray4
        self.joinButton.tintColor = .white
        self.joinButton.setTitle("신청중", for: .normal)
      }else{
        joinView.isHidden = true
      }
    }else{
      joinView.isHidden = false
    }
  }
  
  func initrx(){
    
    joinButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if self.joinButton.currentTitle == "신청중"{
        }else{
          self.joinBoard(self.communityId)
        }
      }).disposed(by: disposeBag)
    
    registerButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityDetailRegisterVC") as! CommunityDetailRegisterVC
        vc.communityId = self!.communityId
        vc.diff = self!.selectedCategory
        self?.navigationController?.pushViewController(vc, animated: true)
      }).disposed(by: disposeBag)
  }
  @IBAction func tapMenu(_ sender: Any) {
    let vc = CommunityDetailMenuPopupVC.viewController()
    vc.isMine.onNext(self.isMine)
    vc.delegate = self
    self.present(vc, animated: true)
  }
  
}

extension CommunityDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if scrollView.isEqual(imageCollectionView) {
      let page = Int(targetContentOffset.pointee.x / imageCollectionView.bounds.width)
      print(page)
      
      thumbnailCountLabel.text = "\(page + 1)/\(imageList.count)"
    }
  }
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if (collectionView == imageCollectionView) {
      if imageList.isEmpty{
        return 1
      }else{
        return imageList.count
      }
    } else{
      return category.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if(collectionView == imageCollectionView){
      if imageList.isEmpty{
        let cell = self.imageCollectionView.dequeueReusableCell(withReuseIdentifier: "Imagepager", for: indexPath)
        guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
          return cell
        }
        thumbnail.image = UIImage(named: "noCommunityDetail")
        return cell
      }else{
        let dict = imageList[indexPath.row]
        let cell = self.imageCollectionView.dequeueReusableCell(withReuseIdentifier: "Imagepager", for: indexPath)
        guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
          return cell
        }
        thumbnail.kf.setImage(with: URL(string: dict.name))
        return cell
      }
      
    }else {
      let cell = self.categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "DetailTapCell", for: indexPath)
      let dict = category[indexPath.row]
      guard let diffLabel = cell.viewWithTag(1) as? UILabel,
            let selectedView = cell.viewWithTag(2)else {
              return cell
            }
      diffLabel.text = dict.rawValue
      if diffLabel.text == selectedCategory {
        diffLabel.textColor = .black
      }else{
        diffLabel.textColor = .lightGray
      }
      selectedView.isHidden = selectedCategory != dict.rawValue
      if (selectedCategory == "공지사항") {
        registerButton.isHidden = !authorityNotice
        initDetailNotice(communityId)
      }else if selectedCategory == "자유게시판" {
        registerButton.isHidden = !authorityBoard
        initDetailBoard(communityId)
      }else{
        registerButton.isHidden = !authorityChat
        initDetailBoard(communityId)
      }
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if(collectionView == imageCollectionView){
      return CGSize(width: APP_WIDTH(), height: collectionView.frame.size.height)
    }else{
      return CGSize(width: (APP_WIDTH()-10)/3, height: collectionView.frame.size.height)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if(collectionView == imageCollectionView){
      if imageList.isEmpty{
        
      }else{
        let vc = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "imageListScroll") as! ImageListWithScrolViewViewController
        vc.indexRow = indexPath.row
        var imageList: [UIImage] = []
        
        if self.imageList.count > 0 {
          for i in 0..<self.imageList.count {
            let dict = self.imageList[i]
            do {
              let data = try! Data(contentsOf: URL(string: dict.name)!)
              let image = UIImage(data: data)
              imageList.append(image!.resizeToWidth(newWidth: self.view.frame.width))
            }
          }
        }
        vc.imageList = imageList
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
      }
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
      if communityNotice.isEmpty{
        return 1
      }else{
        return communityNotice.count
      }
    }else if selectedCategory == "자유게시판"{
      if communityBoard.isEmpty{
        return 1
      }else{
        return communityBoard.count
      }
    }else{
      return communityBoard.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if selectedCategory == "공지사항"{
      if communityNotice.isEmpty{
        let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noList", for: indexPath)
        guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
          return cell
        }
        thumbnail.image = UIImage(named: "noNotice")
        return cell
      }else{
        let dict = communityNotice[indexPath.row]
        let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath)
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
      }
      
    }else if selectedCategory == "자유게시판"{
      if communityBoard.isEmpty{
        let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noList", for: indexPath)
        guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
          return cell
        }
        thumbnail.image = UIImage(named: "noPost")
        return cell
      }else{
        let dict = communityBoard[indexPath.row]
        let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath)
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
        
      }
    }else{
      let dict = communityNotice[indexPath.row]
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
      if communityNotice.isEmpty{
        
      }else{
        let dict = communityNotice[indexPath.row]
        let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityInfoDetailVC") as! CommunityInfoDetailVC
        vc.naviTitle = selectedCategory
        vc.detailId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }else if selectedCategory == "자유게시판"{
      if communityNotice.isEmpty{
        
      }else{
        let dict = communityBoard[indexPath.row]
        let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityInfoDetailVC") as! CommunityInfoDetailVC
        vc.naviTitle = selectedCategory
        vc.detailId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }else{
      let dict = communityBoard[indexPath.row]
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if selectedCategory == "공지사항"{
      if communityNotice.isEmpty{
        return 162
      }else{
        return 80
      }
    }else if selectedCategory == "자유게시판"{
      if communityNotice.isEmpty{
        return 162
      }else{
        return 80
      }
    }else{
      return 100
    }
  }
  
}

