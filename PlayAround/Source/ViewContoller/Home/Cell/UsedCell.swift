//
//  UsedCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/18.
//

import Foundation
import UIKit

class UsedCell: UICollectionViewCell{
  @IBOutlet weak var Thumbnail: UIImageView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var pay: UILabel!
  @IBOutlet weak var listecount: UILabel!
  @IBOutlet weak var dislike: UILabel!
  @IBOutlet weak var backView: UIView!
  
  
  func initdelegate(_ data: UsedList){
    if(data.thumbnail != nil){
      self.Thumbnail?.kf.setImage(with: URL(string: data.thumbnail!))
    }else{
//      self.thumbnail?.kf.setImage(with: URL(string: data.thumbnail ))
    }
    title.text = data.name
    pay.text = "\(data.price.formattedProductPrice() ?? "")원"
//    listecount.text = "\(data.wishCount)"
    listecount.text = "좋아요 \(data.likeCount)"
    dislike.text = "싫어요 \(data.dislikeCount)"
    Thumbnail.cornerRadius = 5
  }
}
