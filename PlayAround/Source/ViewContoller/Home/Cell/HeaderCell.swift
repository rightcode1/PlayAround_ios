//
//  HeaderCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/17.
//

import Foundation
import UIKit

class HeaderCell : UICollectionViewCell {
  @IBOutlet weak var backView: UIView!
  @IBOutlet weak var thumbnail: UIImageView!
  @IBOutlet weak var category: UILabel!
  @IBOutlet weak var Title: UILabel!
  @IBOutlet weak var content: UILabel!
  @IBOutlet weak var distance: UILabel!
  @IBOutlet weak var watchPeople: UILabel!
  @IBOutlet weak var LikeCount: UILabel!
  @IBOutlet weak var DisLikeCount: UILabel!
  
  override func awakeFromNib() {
  }
}
