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
class CommunityDetailVC: BaseViewController{
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
  
  var selectedCategory = "공지사항"
  var category: [Category] = [.공지사항, .자유게시판, .채팅방]
  
  override func viewDidLoad() {
    tabBarController?.tabBar.isHidden = true
    imageCollectionView.dataSource = self
    imageCollectionView.delegate = self
    categoryCollectionView.dataSource = self
    categoryCollectionView.delegate = self
    
    imageCollectionView.register(UINib(nibName: "CollectionViewImageCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewImageCell")
    
    initDetail()
    
  }
  override func viewDidDisappear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = false
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
}

extension CommunityDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if(collectionView == imageCollectionView){
      return imageList.count
    }else{
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
