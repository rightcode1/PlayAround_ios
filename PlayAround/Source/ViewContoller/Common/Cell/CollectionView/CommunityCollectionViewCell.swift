//
//  CommunityCollectionViewCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/27.
//

import UIKit

class CommunityCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var thumbnailImageVIew: UIImageView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var tiltleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var distancLabel: UILabel!
  @IBOutlet weak var peopleLabel: UILabel!
  @IBOutlet weak var likeLabel: UILabel!
  @IBOutlet weak var disLikeLabel: UILabel!
  
  func update(_ data: commuintyList) {
    if(data.images.count != 0){
      self.thumbnailImageVIew.kf.setImage(with: URL(string: data.images[0].name))
    }
    self.categoryLabel.text = data.category
    self.tiltleLabel.text = data.name
    self.contentLabel.text = data.content
    self.distancLabel.text = "\(data.distance)"
    self.peopleLabel.text = "\(data.people)"
    self.likeLabel.text = "좋아요 \(data.likeCount)"
    //    self.disLikeLabel.text = data.li
  }
  
}
