//
//  JoingOkVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/12.
//

import Foundation
import UIKit

class JoinOkVC:BaseViewController{
  override func viewDidLoad() {
    navigationController?.isNavigationBarHidden = true
  }
  @IBAction func tapGoLogin(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "villageDetailVC") as! villageDetailVC
    vc.viewController = "join"
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
