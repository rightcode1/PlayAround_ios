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
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var secretView: UIView!
  
  func update(_ data: CommuintyList) {
    secretView.isHidden = !data.isSecret
    if(data.images.count != 0){
      self.thumbnailImageVIew.kf.setImage(with: URL(string: data.images[0].name))
    }
    self.categoryLabel.text = data.category
    self.tiltleLabel.text = data.name
    self.contentLabel.text = data.content
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    if let createdAtDate = dateFormatter.date(from: data.createdAt) {
      self.dateLabel.text = createdAtDate.toString(dateFormat: "yyyy-MM-dd")
    } else {
      self.dateLabel.text = data.createdAt
    }
    self.distancLabel.text = "\(data.distance)km"
    self.peopleLabel.text = "\(data.people)명"
    self.likeLabel.text = "좋아요 \(data.likeCount)"
    self.disLikeLabel.text = "싫어요 \(data.dislikeCount)" 
  }
  
}
