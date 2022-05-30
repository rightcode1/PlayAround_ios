//
//  FindPwd2VC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/13.
//

import Foundation
import UIKit

class FindPwd2VC:BaseViewController{
  @IBOutlet weak var PwdTextField: UITextField!
  @IBOutlet weak var PwdCheckTextField: UITextField!
  var tel : String?
  var id : String?
  
  
  func ChangePwd(){
    let param = ChangePasswordRequest(loginId: id!, password: PwdTextField.text!, tel: tel!)
    APIProvider.shared.authAPI.rx.request(.changePassword(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.dismissHUD()
        if(value.statusCode <= 202){
          self.backTwo()
        }
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  @IBAction func tapGoLogin(_ sender: Any) {
    ChangePwd()
  }
}
