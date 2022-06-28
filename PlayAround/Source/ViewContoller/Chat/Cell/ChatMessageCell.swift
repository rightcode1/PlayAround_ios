//
//  ChatMessageCell.swift
//  PlayAround
//
//  Created by haon on 2022/06/28.
//

import UIKit

class ChatMessageCell: UITableViewCell {
  @IBOutlet weak var dateView: UIView!
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var contentsView: UIView!
  @IBOutlet weak var profilButton: UIButton!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  
  @IBOutlet weak var bubbleView: UIView!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var messageDateLabel: UILabel!
  @IBOutlet weak var messageReadCountLabel: UILabel!
  @IBOutlet weak var myMessageDateLabel: UILabel!
  @IBOutlet weak var myMessageReadCountLabel: UILabel!
  
  @IBOutlet weak var widthConstraint: NSLayoutConstraint!
  @IBOutlet weak var bubbleTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var bubbleLeftConstraint: NSLayoutConstraint!
  @IBOutlet weak var bubbleRightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var noticeCommentView: UIView!
  @IBOutlet weak var noticeCommentLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bubbleView.layer.cornerRadius = 7.5
    photoImageView.layer.cornerRadius = 7.5
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  func setHeaderDate(beforeData: MessageData?, currentData: MessageData, nextData: MessageData?) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let beforeCreatedAtDate = dateFormatter.date(from: beforeData?.createdAt ?? "") ?? Date()
    let createdAtDate = dateFormatter.date(from: currentData.createdAt ?? "") ?? Date()
    let nextCreatedAtDate = dateFormatter.date(from: nextData?.createdAt ?? "") ?? Date()
    
    dateFormatter.dateFormat = "yyyy년 MM월 dd일"
    
    let beforeCreatedAtString = dateFormatter.string(from: beforeCreatedAtDate)
    let createdAtString = dateFormatter.string(from: createdAtDate)
    let nextCreatedAtString = dateFormatter.string(from: nextCreatedAtDate)
    
    dateLabel.text = createdAtString
    
    if beforeData != nil {
      if beforeCreatedAtString == createdAtString {
        dateView.isHidden = true
      } else {
        dateView.isHidden = false
      }
    } else {
      dateView.isHidden = false
    }

//    if nextData != nil {
//      if createdAtString == nextCreatedAtString {
//        bottomSpaceView.isHidden = true
//      } else {
//        bottomSpaceView.isHidden = false
//      }
//    } else {
//      bottomSpaceView.isHidden = true
//    }
  }
  
  func update(_ data: MessageData, myId: Int) {
    messageLabel.isHidden = data.type == .file
    photoImageView.isHidden = data.type == .message
    
    let isMine = myId == data.userId
    
    profileImage.isHidden = isMine
    profilButton.isHidden = isMine
    userNameLabel.isHidden = isMine
    
    bubbleView.backgroundColor = isMine ? UIColor(displayP3Red: 255/255, green: 230/255, blue: 192/255, alpha: 1.0) : UIColor(displayP3Red: 255/255, green: 230/255, blue: 192/255, alpha: 1.0)

    messageDateLabel.isHidden = isMine
    messageReadCountLabel.isHidden = isMine
    
    myMessageDateLabel.isHidden = !isMine
    myMessageReadCountLabel.isHidden = !isMine
    
    if data.thumbnail != nil && !(data.thumbnail ?? "default").contains(find: "default") {
      profileImage.kf.setImage(with: URL(string: data.thumbnail!))
    } else {
      profileImage.image = UIImage(named: "defaultBoardImage")
    }
    
    let message = data.message ?? ""
    let widthValue = estimateFrameForText(message).width + 14.5
    
    messageLabel.textAlignment = isMine ? .right : .left
    messageLabel.text = message
    widthConstraint.constant = widthValue
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier:"ko_KR")
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let createdAtDate = dateFormatter.date(from: data.createdAt ?? "") ?? Date()

    let date = createdAtDate.toString(dateFormat: "a HH:mm")
    let isEveryoneRead = (data.readCount ?? 0) == 0
    
    messageDateLabel.text = date
    myMessageDateLabel.text = date
    
    messageReadCountLabel.isHidden = isEveryoneRead
    myMessageReadCountLabel.isHidden = isEveryoneRead
    messageReadCountLabel.text = "\(data.readCount ?? 0)"
    myMessageReadCountLabel.text = "\(data.readCount ?? 0)"
    
    if isMine {
      bubbleTopConstraint.constant = 15
      bubbleRightConstraint.constant = 15
      bubbleLeftConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubbleRightConstraint.constant
    } else {
      bubbleTopConstraint.constant = 31
      bubbleLeftConstraint.constant = 63.5
      bubbleRightConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubbleLeftConstraint.constant
    }

  }
  
  func estimateFrameForText(_ text: String) -> CGRect {
    let size = CGSize(width: 250, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .medium)], context: nil)
  }
  
}
