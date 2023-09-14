//
//  FooterCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/19.
//

import Foundation
import UIKit
import RxSwift

protocol moreProtocol{
  func moreButton(diff:String)
}

class MainFooterCell: UITableViewCell{
  @IBOutlet weak var backView: UIView!
  @IBOutlet weak var button: UIButton!
    
    var disposeBag = DisposeBag()
    var delegate : moreProtocol?
  
    func initCell(diff: String){
    backView?.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 0, y: 1.5, blur: 5, spread: 0)
    backView?.layer.cornerRadius = 10
    backView?.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMaxYCorner, .layerMinXMaxYCorner)
    button.rx.tap
          .bind(onNext: { [weak self] in
            guard let self = self else { return }
              self.delegate?.moreButton(diff: diff)
          }).disposed(by: disposeBag)
  }
}
