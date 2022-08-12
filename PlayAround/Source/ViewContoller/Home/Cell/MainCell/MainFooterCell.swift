//
//  FooterCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/19.
//

import Foundation
import UIKit

class MainFooterCell: UITableViewCell{
  @IBOutlet weak var backView: UIView!
  @IBOutlet weak var button: UIButton!
  
  
  func initCell(){
    
    backView?.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 0, y: 1.5, blur: 5, spread: 0)
    backView?.layer.cornerRadius = 10
    backView?.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMaxYCorner, .layerMinXMaxYCorner)
  }
}
