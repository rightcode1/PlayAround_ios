//
//  FollowListCell.swift
//  PlayAround
//
//  Created by haon on 2022/06/23.
//

import UIKit

protocol FollowListCellDelegate {
  func registFollow(indexPath: IndexPath)
}

class FollowListCell: UITableViewCell {
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  
  @IBOutlet weak var followButton: UIButton!
  
  var indexPath: IndexPath?
  var delegate: FollowListCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  @IBAction func tapFollow(_ sender: UIButton) {
    delegate?.registFollow(indexPath: self.indexPath!)
  }
  
  func initFollowButton(_ isFollow: Bool) {
    followButton.backgroundColor = isFollow ? .white : UIColor(red: 243/255, green: 112/255, blue: 34/255, alpha: 1.0)
    followButton.layer.borderWidth = isFollow ? 1 : 0
    followButton.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0).cgColor
    followButton.setTitleColor(isFollow ? UIColor(red: 188/255, green: 188/255, blue: 188/255, alpha: 1.0) : .white, for: .normal)
    followButton.setTitle(isFollow ? "팔로잉" : "+팔로우", for: .normal)
  }
  
  func update(_ data: Follow) {
    if data.thumbnail != nil {
      thumbnailImageView.kf.setImage(with: URL(string: data.thumbnail ?? ""))
    } else {
      thumbnailImageView.image = UIImage(named: "defaultProfileImage")
    }
    nameLabel.text = data.name
    initFollowButton(data.isFollowing)
  }
  
}
