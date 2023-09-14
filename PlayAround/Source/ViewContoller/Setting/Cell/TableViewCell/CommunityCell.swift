//
//  CommunityCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/07/06.
//

import Foundation
import UIKit

class CommunityCell:UITableViewCell{
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var kmLabel: UILabel!
  @IBOutlet weak var peopleLabel: UILabel!
  @IBOutlet weak var likeLabel: UILabel!
  @IBOutlet weak var disLikeLabel: UILabel!
  
  var dict : CommuintyList?
  
  func initcell(_ data: CommuintyList){
    dict = data
      if dict?.images.count != 0 {
          thumbnailImageView.kf.setImage(with: URL(string: dict?.images[0].name ?? ""))
      }
    titleLabel.text = dict?.name
    contentLabel.text = dict?.content
    kmLabel.text = "\(dict?.distance ?? 0)km"
    peopleLabel.text = "\(dict?.people ?? 0)명"
    likeLabel.text = "좋아요 \(dict?.likeCount ?? 0)"
    disLikeLabel.text = "싫어요 \(dict?.dislikeCount ?? 0)"
  }
  
  
}
