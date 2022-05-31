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
  
  func update(_ data: FoodListData) {
    if let thumbnailURL = data.thumbnail {
      thumbnailImageView.kf.setImage(with: URL(string: thumbnailURL))
    }
    
    foodStatusStackView.arrangedSubviews[0].isHidden = data.status == .조리예정
    foodStatusStackView.arrangedSubviews[1].isHidden = data.status == .조리완료
    
    titleLabel.text = data.name
    priceLabel.text = "\(data.price.formattedProductPrice() ?? "0") 달란트"
    wishCountLabel.text = "\(data.wishCount)"
    likeCountLabel.text = "좋아요 \(data.likeCount)"
    disLikeCountLabel.text = "싫어요 \(data.dislikeCount)"
  }
  
}