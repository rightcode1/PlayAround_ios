//
//  CollectionViewImageCell.swift
//  PlayAround
//
//  Created by haon on 2022/05/23.
//

import UIKit

class CollectionViewImageCell: UICollectionViewCell {

  @IBOutlet weak var imageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  func setImage(_ data:Image){
    if(data != nil){
        self.imageView?.kf.setImage(with: URL(string: data.name))
    }
  }
}
