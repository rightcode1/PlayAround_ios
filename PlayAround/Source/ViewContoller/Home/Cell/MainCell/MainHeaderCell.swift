//
//  HeaderCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/19.
//

import Foundation
import UIKit

class MainHeaderCell : UITableViewCell{
  @IBOutlet weak var headerTitle: UILabel!
  @IBOutlet weak var headerContent: UILabel!
  @IBOutlet weak var headerContentHeight: NSLayoutConstraint!
  @IBOutlet weak var headerImage: UIImageView!
  @IBOutlet weak var headerView: UIView!
  
  func initHedaer(_ diff: String){
    if diff == "커뮤니티"{
      headerTitle.text = "실시간 커뮤니티"
      headerContent.isHidden = false
      headerContentHeight.constant = 18
      headerImage.image = UIImage(named: "homePeople")
    }else{
      headerTitle.text = "실시간 따끈한 반찬"
      headerContent.isHidden = true
      headerContentHeight.constant = 0
      headerImage.image = UIImage(named: "homeFood")
    }
    headerView.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 0, y: 1.5, blur: 5, spread: 0)
    headerView?.layer.cornerRadius  = 10
    headerView?.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
  
  
}
//  override func layoutSubviews() {
//      super.layoutSubviews()
//    roundCorners([.topLeft, .topRight], radius: 10)
//    layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 0, y: 1.5, blur: 5, spread: 0)
//  }
}
