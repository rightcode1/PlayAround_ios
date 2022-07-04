//
//  InquiryListCell.swift
//  PlayAround
//
//  Created by haon on 2022/06/20.
//

import UIKit

class InquiryListCell: UITableViewCell {
  
  @IBOutlet weak var noCommentStatusButton: UIButton!
  @IBOutlet weak var commentedStatusButton: UIButton!
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var arrowImageView: UIImageView!
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var contentStackView: UIStackView!
  @IBOutlet var contentTitleLabel: UILabel!
  @IBOutlet var contentLabel: UILabel!
  
  @IBOutlet weak var commentStackView: UIStackView!
  @IBOutlet weak var commentLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func update(_ data: InquiryListData) {
    let isCommented = data.comment != nil
    
    noCommentStatusButton.isHidden = isCommented
    commentedStatusButton.isHidden = !isCommented
    
    titleLabel.text = data.title
    arrowImageView.image = (data.isOpened ?? false) ? UIImage(named: "arrowUpGray") : UIImage(named: "arrowDownGray")
    dateLabel.text = data.createdAt
    
    contentStackView.isHidden = !(data.isOpened ?? false)
    contentTitleLabel.text = data.title
    contentLabel.text = data.content
    
    commentStackView.isHidden = !(data.isOpened ?? false) || !isCommented
    commentLabel.text = data.comment
  }
  
}
