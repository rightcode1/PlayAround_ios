//
//  CommunityDetailNoticeVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/31.
//

import Foundation
import UIKit

class CommunityInfoDetailVC:BaseViewController{
  @IBOutlet weak var mainTableView: UITableView!
  @IBOutlet weak var imageCollectionView: UICollectionView!
  
  @IBOutlet weak var infoImageView: UIImageView!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var voteHiddenView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var commentCountLabel: UILabel!
  
  var naviTitle: String?
  var detailId: Int?
  var imageList: [Image?] = []
  var comment: [Comment] = []
  
  override func viewDidLoad() {
    navigationController?.title  = naviTitle
    self.showHUD()
    initDelegate()
    
    if naviTitle == "공지사항"{
      initNoticeDetail()
    }else{
      initBoardDetail()
    }
  }
  
  func initDelegate(){
    mainTableView.delegate = self
    mainTableView.dataSource = self
    voteHiddenView.isHidden = true
    infoImageView.isHidden = true
    imageCollectionView.delegate = self
    imageCollectionView.dataSource = self
    
    imageCollectionView.register(UINib(nibName: "CollectionViewImageCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewImageCell")

  }
  
  func initNoticeDetail() {
    APIProvider.shared.communityAPI.rx.request(.CommuntyNoticeDetail(id: detailId!))
      .filterSuccessfulStatusCodes()
      .map(CommunityInfoDetailResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          print(value.data)
          self.initNoticeComment(value.data.id)
          self.initDetail(value.data)
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initNoticeComment(_ id: Int) {
    APIProvider.shared.communityAPI.rx.request(.CommuntyNoticeComment(id: id))
      .filterSuccessfulStatusCodes()
      .map(CommunityCommentResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          print(value.list)
          self.commentCountLabel.text = "\(value.list.count)"
          self.comment = value.list
          self.mainTableView.reloadData()
        }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initBoardDetail() {
    APIProvider.shared.communityAPI.rx.request(.CommuntyBoardDetail(id: detailId!))
      .filterSuccessfulStatusCodes()
      .map(CommunityInfoDetailResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          print(value.data)
          self.initBoardComment(value.data.id)
          self.initDetail(value.data)
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initBoardComment(_ id: Int) {
    APIProvider.shared.communityAPI.rx.request(.CommuntyBoardComment(id: id))
      .filterSuccessfulStatusCodes()
      .map(CommunityCommentResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          self.commentCountLabel.text = "\(value.list.count)"
          self.comment = value.list
          self.mainTableView.reloadData()
        }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initDetail(_ data: CommunityInfo){
    if(data.images.count != 0){
      imageList = data.images
      imageCollectionView.isHidden = false
    }else{
      imageCollectionView.isHidden = true
    }
    mainTableView.layoutTableHeaderView()
    titleLabel.text = data.title
    userNameLabel.text = data.user.name
    dateLabel.text = data.createdAt
    contentLabel.text = data.content
    if(data.user.thumbnail != nil){
      userImageView?.kf.setImage(with: URL(string: data.user.thumbnail!))
    }
    imageCollectionView.reloadData()
    self.dismissHUD()
  }
  
}

extension CommunityInfoDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.imageCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewImageCell", for: indexPath)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: APP_WIDTH(), height: 225)
  }
  
}
extension CommunityInfoDetailVC: UITableViewDataSource, UITableViewDelegate {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comment.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
    let dict = comment[indexPath.row]
    return cell
  }

//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let dict = comment[indexPath.row]
    
    let mainWidth = UIScreen.main.bounds.width
    
    let textHeight = dict.content.height(withConstrainedWidth: mainWidth - (dict.depth == 1 ? 72 : 112), font: .systemFont(ofSize: 13))
    
    return (textHeight + 57)
  }

}

