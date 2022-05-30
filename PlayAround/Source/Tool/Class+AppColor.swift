//
//  Class+AppColor.swift
//  coffit
//
//  Created by hoonKim on 2021/10/22.
//

import UIKit

class AppColor {
  let signatureColor = #colorLiteral(red: 1, green: 0.2431372549, blue: 0.4666666667, alpha: 1)
  
  // text Color
  let invalidTextColor = #colorLiteral(red: 0.9843137255, green: 0.231372549, blue: 0.231372549, alpha: 1)
  let validTextColor = #colorLiteral(red: 0.2823529412, green: 0.7333333333, blue: 0.4705882353, alpha: 1)
  
  // button Color
  let buttonDisableBackGroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
  let buttonDisableTitleColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
  
  let buttonDisableBorderColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
  let buttonDisableTitleGrayColor = #colorLiteral(red: 0.3764705882, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
  
  let buttonEnableBackGroundColor = #colorLiteral(red: 0.9607843137, green: 0.9764705882, blue: 0.9882352941, alpha: 1)
  let buttonEnableBorderColor = #colorLiteral(red: 0.8941176471, green: 0.9137254902, blue: 0.9490196078, alpha: 1)
  let buttonEnableTitleColor = #colorLiteral(red: 0.5607843137, green: 0.6078431373, blue: 0.7019607843, alpha: 1)
  
  
  func initEnableButtonWithSignatureColor(_ button: UIButton) {
    button.isEnabled = true
    button.backgroundColor = signatureColor
    
    button.layer.borderWidth = 0
    
    button.setTitleColor(.white, for: .normal)
  }
  
  func initEnableButtonColor(_ button: UIButton) {
    button.isEnabled = true
    button.backgroundColor = buttonEnableBackGroundColor
    
    button.layer.borderWidth = 1
    button.layer.borderColor = buttonEnableBorderColor.cgColor
    
    button.setTitleColor(buttonEnableTitleColor, for: .normal)
  }
  
  func initDisableButtonColor(_ button: UIButton, _ isEnable: Bool = false) {
    button.isEnabled = isEnable
    button.backgroundColor = buttonDisableBackGroundColor
    
    button.layer.borderWidth = 0
    button.layer.borderColor = buttonEnableBorderColor.cgColor
    
    button.setTitleColor(buttonDisableTitleColor, for: .normal)
  }
  
  func initSelectedButtonColor(_ button: UIButton) {
    button.layer.borderWidth = 1
    button.layer.borderColor = signatureColor.cgColor
    
    button.setTitleColor(signatureColor, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
  }
  
  func initNotSelectedButtonColor(_ button: UIButton) {
    button.layer.borderWidth = 1
    button.layer.borderColor = buttonDisableBorderColor.cgColor
    
    button.setTitleColor(buttonDisableTitleGrayColor, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
  }
}
