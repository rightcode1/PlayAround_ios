//
//  TableView2Cell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/16.
//

import UIKit

class TableView2Cell: UITableViewCell {
  @IBOutlet weak var thumbnail: UIImageView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var price: UILabel!
  @IBOutlet weak var wishCount: UILabel!
  @IBOutlet weak var likeCount: UILabel!
  @IBOutlet weak var disLikeCount: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  func initdelegate(_ data: UsedList){
    if(thumbnail != nil){
      self.thumbnail?.kf.setImage(with: URL(string: data.thumbnail! ))
    }else{
//      self.thumbnail?.kf.setImage(with: URL(string: data.thumbnail ))
    }
    title.text = data.name
    price.text = "\(data.price) 달란트"
    wishCount.text = "\(data.wishCount)"
    likeCount.text = "좋아요 \(data.likeCount)"
    disLikeCount.text = "싫어요 \(data.dislikeCount)"
  }
    
}
