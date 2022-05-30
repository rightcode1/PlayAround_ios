//
//  JoingOkVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/12.
//

import Foundation

class JoinOkVC:BaseViewController{
  override func viewDidLoad() {
    navigationController?.isNavigationBarHidden = true
  }
  @IBAction func tapGoLogin(_ sender: Any) {
    self.backTwo()
  }
}
