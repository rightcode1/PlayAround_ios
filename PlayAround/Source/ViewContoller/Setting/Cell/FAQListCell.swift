//
//  FAQListCell.swift
//  academyNow
//
//  Created by haon on 2022/06/11.
//

import UIKit

class FAQListCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var arrowImageView: UIImageView!
  
  @IBOutlet var contentContainerView: UIView!
  @IBOutlet var contentLabel: UILabel!
  
  var index: Int = -1
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func update(_ data: FAQListData) {
    titleLabel.text = data.title
    arrowImageView.image = (data.isOpened ?? false) ? UIImage(named: "arrowUpGray") : UIImage(named: "arrowDownGray")
    contentContainerView.isHidden = !(data.isOpened ?? false)
    contentLabel.text = data.content
  }
  
}
