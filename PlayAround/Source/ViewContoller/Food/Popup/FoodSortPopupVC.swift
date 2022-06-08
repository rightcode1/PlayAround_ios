//
//  FoodSortPopupVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/08.
//

import UIKit

class FoodSortPopupVC: BaseViewController, ViewControllerFromStoryboard {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  static func viewController() -> FoodSortPopupVC {
    let viewController = FoodSortPopupVC.viewController(storyBoardName: "Food")
    return viewController
  }
  
  
}
