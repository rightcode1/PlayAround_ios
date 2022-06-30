//
//  ChatRoomListCell.swift
//  PlayAround
//
//  Created by haon on 2022/06/27.
//

import UIKit

class ChatRoomListCell: UITableViewCell {
  @IBOutlet weak var thumbnailImageView: UIImageView!
  
  @IBOutlet weak var isSecretView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var messageCountView: UIView!
  @IBOutlet weak var messageCountLabel: UILabel!
  
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var subNameLabel: UILabel!
  @IBOutlet weak var userCountImageView: UIImageView!
  @IBOutlet weak var userCountLabel: UILabel!
  
  @IBOutlet weak var messageLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  func update(_ data: ChatRoomData) {
    if data.thumbnail != nil && !(data.thumbnail ?? "default").contains(find: "default") {
      thumbnailImageView.kf.setImage(with: URL(string: data.thumbnail!))
    } else {
      thumbnailImageView.image = UIImage(named: "defaultBoardImage")
    }
    
    isSecretView.isHidden = (data.isSecret ?? 0) == 0
    nameLabel.text = data.name
    
    messageCountLabel.text = "\(data.count ?? 0)"
    messageCountView.isHidden = (data.count ?? 0) <= 0
    messageCountView.layer.cornerRadius = messageCountView.frame.height / 2
    
    dateLabel.text = data.updatedAt
    
    subNameLabel.text = data.from
    
    userCountImageView.isHidden = data.communityId == nil
    userCountLabel.isHidden = data.communityId == nil
    userCountLabel.text = "\(data.userCount ?? 0)명"
    
    messageLabel.text = data.type == "message" ? data.message : "사진"
  }
  
}
