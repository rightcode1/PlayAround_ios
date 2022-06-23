//
//  ChatRoomLIstVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/23.
//

import UIKit

class ChatRoomLIstVC: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
  }
  
}
