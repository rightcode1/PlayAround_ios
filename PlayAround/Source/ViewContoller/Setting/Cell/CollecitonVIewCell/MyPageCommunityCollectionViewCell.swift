//
//  MyPageCommunityCollectionViewCell.swift
//  PlayAround
//
//  Created by haon on 2022/06/22.
//

import UIKit

class MyPageCommunityCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var isSecretButton: UIButton!
  @IBOutlet weak var categoryButton: UIButton!
  @IBOutlet weak var tiltleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var distancLabel: UILabel!
  @IBOutlet weak var peopleCountLabel: UILabel!
  @IBOutlet weak var likeCountLabel: UILabel!
  @IBOutlet weak var disLikeCountLabel: UILabel!
  
  func update(_ data: CommuintyList) {
    if(data.images.count != 0){
      thumbnailImageView.kf.setImage(with: URL(string: data.images[0].name))
    } else {
      thumbnailImageView.image = UIImage(named: "defaultBoardImage")
    }
    isSecretButton.isHidden = !data.isSecret
    categoryButton.setTitle("  \(data.category)  ", for: .normal)
    
    tiltleLabel.text = data.name
    contentLabel.text = data.content
    distancLabel.text = "\(data.distance)KM"
    peopleCountLabel.text = "\(data.people)명"
    likeCountLabel.text = "좋아요 \(data.likeCount)"
    disLikeCountLabel.text = "싫어요 \(data.dislikeCount)"
  }
}
