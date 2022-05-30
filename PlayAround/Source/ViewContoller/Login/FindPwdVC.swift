//
//  FindPwdVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/12.
//

import Foundation
import UIKit

class FindPwdVC :BaseViewController{
  @IBOutlet weak var EmailTextField: UITextField!
  @IBOutlet weak var PhoneTextField: UITextField!
  @IBOutlet weak var SmsTextField: UITextField!
  var checkId = false
  
  func smsSend(){
    let param = SendCodeRequest(tel: PhoneTextField.text!, diff: .update)
    APIProvider.shared.authAPI.rx.request(.sendCode(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "인증번호를 전송했습니다.") {
        }
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  func smsCheck(){
    APIProvider.shared.authAPI.rx.request(.confirm(tel: PhoneTextField.text!, confirm: SmsTextField.text!))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "인증되었습니다.") {
        }
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  func idcheck(){
    APIProvider.shared.authAPI.rx.request(.isExistLoginId(email: EmailTextField.text!))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.dismissHUD()
        if(value.message == "아이디가 없습니다."){
          self.callOkActionMSGDialog(message: "아이디가 존재하지않습니다.") {
            self.checkId = true
          }
        }else{
          self.callOkActionMSGDialog(message: "아이디가 존재합니다.") {
          }
        }
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }

  @IBAction func tapCheckEmail(_ sender: Any) {
    idcheck()
  }
  @IBAction func tapSendSms(_ sender: Any) {
    smsSend()
  }
  @IBAction func tapCheckSms(_ sender: Any) {
    smsCheck()
  }
  @IBAction func tapGoPwd2(_ sender: Any) {
    if checkId{
      let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "FindPwd2VC") as! FindPwd2VC
      vc.id = EmailTextField.text
      vc.tel = PhoneTextField.text
      self.navigationController?.pushViewController(vc, animated: true)
    }else{
      self.callMSGDialog(message: "이메일 중복검사를 해주세요.")
    }
  }
}
