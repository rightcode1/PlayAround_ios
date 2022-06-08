//
//  FoodCommentListCell.swift
//  PlayAround
//
//  Created by haon on 2022/06/02.
//

import UIKit

protocol FoodCommentListCellDelegate {
  func setReplyInfo(commentId: Int, userName: String)
}

class FoodCommentListCell: UITableViewCell {
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var thumbnailImageViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var foodLevelImageView: UIImageView!
  
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var commentLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var replyButton: UIButton!
  
  var delegate: FoodCommentListCellDelegate?
  var commentId: Int?
  var userName: String?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
  @IBAction func tapReply(_ sender: UIButton) {
    delegate?.setReplyInfo(commentId: commentId ?? 0, userName: userName ?? "")
  }
  
  func foodLevelImage(level: Int) -> UIImage {
    return UIImage(named: "foodLevel\(level)") ?? UIImage()
  }
  
  func update(_ data: FoodCommentListData) {
    commentId = data.id
    userName = data.user.name
    
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
