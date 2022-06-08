//
//  CheckCrimeHistoryPopupVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/08.
//

import UIKit

class CheckCrimeHistoryPopupVC: BaseViewController, ViewControllerFromStoryboard {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  static func viewController() -> CheckCrimeHistoryPopupVC {
    let viewController = CheckCrimeHistoryPopupVC.viewController(storyBoardName: "Food")
    return viewController
  }
  
}
