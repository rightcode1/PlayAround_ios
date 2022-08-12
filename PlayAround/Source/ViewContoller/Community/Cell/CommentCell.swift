//
//  CommentCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/06/13.
//

import Foundation
import UIKit
import SwiftUI

protocol tapCommentProtocol{
  func tapComment(commentId: Int?, userName: String)
}

class CommentCell:UITableViewCell{
  @IBOutlet weak var commentDepth: NSLayoutConstraint!
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  var data: Comment?
  var delegate: tapCommentProtocol?
  
  func initComment(_ data: Comment){
    self.data = data
    
    let isReply = data.depth == 1
      thumbnailImageView.kf.setImage(with: URL(string: data.user.thumbnail ?? ""))
      commentDepth.constant = isReply ? 50 : 15
    
    nameLabel.text = data.user.name
    contentLabel.text = data.content
    dateLabel.text = data.createdAt
  }
  func usedLevelImage(level: Int) -> UIImage {
    return UIImage(named: "usedLevel\(level)") ?? UIImage()
  }
  @IBAction func tapComment(_ sender: Any) {
    delegate?.tapComment(commentId: data?.id,userName: data?.user.name ?? "")
  }
  
}

