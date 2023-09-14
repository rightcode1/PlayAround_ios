//
//  PushAlarmSettingViewController.swift
//  ppuryo
//
//  Created by hoonKim on 2021/05/27.
//

import UIKit

class PushAlarmSettingViewController: BaseViewController {
  @IBOutlet weak var foodPushMessageSwitch: UISwitch!
    @IBOutlet weak var foodPushChatSwitch: UISwitch!

  @IBOutlet weak var usedMessagePushSwitch: UISwitch!
    @IBOutlet weak var usedChatPushSwitch: UISwitch!
    
    
    @IBOutlet weak var communityNoticePushSwitch: UISwitch!
      @IBOutlet weak var communityBoardSwitch: UISwitch!
    @IBOutlet weak var communityMessagePushSwitch: UISwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tabBarController?.tabBar.isHidden = true
    
    
  }
  
  @IBAction func pushOnOff(_ sender: UISwitch) {
      switch sender.tag{
      case 0:
          break
      case 1:
          break
      case 2:
          break
      case 3:
          break
      case 4:
          break
      case 5:
          break
      case 6:
          break
      case 7:
          break
      default:
          break
      }
    
  }
  
}
