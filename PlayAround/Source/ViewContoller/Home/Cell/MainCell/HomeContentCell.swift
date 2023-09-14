//
//  MainContentCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/07/19.
//

import Foundation
import UIKit

class HomeContentCell : UITableViewCell{
  @IBOutlet weak var colletionView: UICollectionView!
  @IBOutlet weak var backView: UIView!
  
  var selectCategory : String?
  var communityList: [CommuintyList] = []{
    didSet{
      colletionView.reloadData()
    }
  }
  var foodList : [FoodListData] = []{
    didSet{
      colletionView.reloadData()
    }
  }
  var HomeVc: HomeVC?
  
  func initCommunity(_ data: [CommuintyList],_ diff:String){
    selectCategory = diff
    communityList = data
    backView?.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 0, y: 1.5, blur: 5, spread: 0)
    backView?.layer.cornerRadius  = 10
    colletionView.delegate = self
    colletionView.dataSource = self
//    let layout = UICollectionViewFlowLayout()
//    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    layout.itemSize = CGSize(width: APP_WIDTH(), height: 122)
//    layout.minimumInteritemSpacing = 0
//    layout.minimumLineSpacing = 0
//    layout.invalidateLayout()
//    layout.scrollDirection = .vertical
  }
  
    func initFood(_ data: [FoodListData],_ diff:String){
      selectCategory = diff
      foodList = data
    
    colletionView.delegate = self
    colletionView.dataSource = self
//
//    let layout = UICollectionViewFlowLayout()
//    layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
//    layout.itemSize = CGSize(width: (APP_WIDTH() - 70) / 2, height: height )
//    layout.minimumInteritemSpacing = 10
//    layout.minimumLineSpacing = 10
//    layout.scrollDirection = .vertical
//
//    colletionView.collectionViewLayout = layout
    backView?.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 0, y: 1.5, blur: 5, spread: 0)
    backView?.layer.cornerRadius  = 10

//    colletionView.register(UINib(nibName: "FoodListCell", bundle: nil), forCellWithReuseIdentifier: "cell")
  }
  
}

extension HomeContentCell: UICollectionViewDelegate, UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if selectCategory == "커뮤니티"{
      return communityList.count
    }else{
      return foodList.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if selectCategory == "커뮤니티"{
      let cell = colletionView.dequeueReusableCell(withReuseIdentifier: "Community", for: indexPath)
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
    }else{
      let cell = colletionView.dequeueReusableCell(withReuseIdentifier: "Food", for: indexPath)
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
      thumbnail.kf.setImage(with: URL(string: dict.thumbnail ?? ""))
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
      
    }
  }
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if selectCategory == "커뮤니티"{
      let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityDetailVC") as! CommunityDetailVC
      vc.communityId = communityList[indexPath.row].id
      HomeVc?.navigationController?.pushViewController(vc, animated: true)
    }else{
      let dict = foodList[indexPath.row]
      let vc = FoodDetailVC.viewController()
      vc.foodId = dict.id
      HomeVc?.navigationController?.pushViewController(vc, animated: true)
    }
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if selectCategory == "커뮤니티"{
      return CGSize(width: (APP_WIDTH() - 50), height: 122)
    }else{
      let height = ((APP_WIDTH() - 40) / 2) / 142 * 100 + 83
      return CGSize(width: (APP_WIDTH() - 70/2), height: height)
    }
  }
    
}
