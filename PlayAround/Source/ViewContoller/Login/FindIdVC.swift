//
//  FindIdVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/12.
//

import Foundation
import UIKit

class FindIdVC:BaseViewController{
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var smsTextField: UITextField!
  
  func smsSend(){
    let param = SendCodeRequest(tel: phoneTextField.text!, diff: .find)
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
    APIProvider.shared.authAPI.rx.request(.confirm(tel: phoneTextField.text!, confirm: smsTextField.text!))
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
  
  func findId(){
    let param = FindMyIdRequest(tel: phoneTextField.text!)
    APIProvider.shared.authAPI.rx.request(.findId(param: param))
      .filterSuccessfulStatusCodes()
      .map(FindIdResponse.self)
      .subscribe(onSuccess: { value in
        self.dismissHUD()
        if(value.statusCode <= 202){
            let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "FindId2VC") as! FindId2VC
          vc.myIdTextField.text = value.data?.loginId
            self.navigationController?.pushViewController(vc, animated: true)
        }
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  
  @IBAction func tapSendSms(_ sender: Any) {
    smsSend()
  }
  @IBAction func tapConfirmSms(_ sender: Any) {
    smsCheck()
  }
  @IBAction func tapGoIdFind2(_ sender: Any) {
    findId()
  }
}
