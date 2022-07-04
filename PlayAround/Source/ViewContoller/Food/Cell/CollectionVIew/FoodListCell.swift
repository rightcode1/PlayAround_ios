//
//  FoodListCell.swift
//  PlayAround
//
//  Created by haon on 2022/05/23.
//

import UIKit

class FoodListCell: UICollectionViewCell {
  @IBOutlet weak var thumbnailImageView: UIImageView!
  
  @IBOutlet weak var foodStatusStackView: UIStackView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var wishCountLabel: UILabel!
  @IBOutlet weak var likeCountLabel: UILabel!
  @IBOutlet weak var disLikeCountLabel: UILabel!
  
  @IBOutlet weak var soldOutView: UIView!
  
  func update(_ data: FoodListData, isDetail: String? = nil) {
    if let thumbnailURL = data.thumbnail {
      thumbnailImageView.kf.setImage(with: URL(string: thumbnailURL))
    }
    
    if isDetail != nil {
      foodStatusStackView.arrangedSubviews[0].isHidden = true
      foodStatusStackView.arrangedSubviews[1].isHidden = true
    } else {
      foodStatusStackView.arrangedSubviews[0].isHidden = data.status == .조리예정
      foodStatusStackView.arrangedSubviews[1].isHidden = data.status == .조리완료
    }
    
    titleLabel.text = data.name
    priceLabel.text = "\(data.price.formattedProductPrice() ?? "0") 달란트"
    wishCountLabel.text = "\(data.wishCount)"
    likeCountLabel.text = "좋아요 \(data.likeCount)"
    disLikeCountLabel.text = "싫어요 \(data.dislikeCount)"
  }
  
  func update(_ data: UsedListData) {
    foodStatusStackView.arrangedSubviews[0].isHidden = true
    foodStatusStackView.arrangedSubviews[1].isHidden = true
    
    likeCountLabel.isHidden = true
    disLikeCountLabel.isHidden = true
    
    if let thumbnailURL = data.thumbnail {
      thumbnailImageView.kf.setImage(with: URL(string: thumbnailURL))
    }
    
    titleLabel.text = data.name
    priceLabel.text = "\(data.price.formattedProductPrice() ?? "0") 달란트"
    wishCountLabel.text = "\(data.wishCount)"
    likeCountLabel.text = "좋아요 \(data.likeCount)"
    disLikeCountLabel.text = "싫어요 \(data.dislikeCount)"
  }
  
}
