//
//  SettingVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/20.
//

import UIKit

class SettingVC: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  @IBAction func tapPorfile(_ sender: Any) {
    let vc = UIStoryboard.init(name: "MyPage", bundle: nil).instantiateViewController(withIdentifier: "UpdateProfileVC") as! UpdateProfileVC
    self.navigationController?.pushViewController(vc, animated: true)
  
  }
  
  @IBAction func tapVillage(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "VillageListVC") as! VillageListVC
    self.navigationController?.pushViewController(vc, animated: true)
  
  }
}
