//
//  FoodCommentListCell.swift
//  PlayAround
//
//  Created by haon on 2022/06/02.
//

import UIKit

class FoodCommentListCell: UITableViewCell {
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var thumbnailImageViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var foodLevelImageView: UIImageView!
  
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var commentLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var replyButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
  func foodLevelImage(level: Int) -> UIImage {
    return UIImage(named: "foodLevel\(level)") ?? UIImage()
  }
  
  func update(_ data: FoodCommentListData) {
    let isReply = data.depth == 1
    thumbnailImageView.kf.setImage(with: URL(string: data.user.thumbnail ?? ""))
    thumbnailImageViewLeadingConstraint.constant = isReply ? 50 : 15
    foodLevelImageView.image = foodLevelImage(level: data.user.foodLevel ?? 1)
    
    userNameLabel.text = data.user.name
    commentLabel.text = data.content
    dateLabel.text = data.createdAt
    replyButton.isHidden = isReply
  }
  
}
