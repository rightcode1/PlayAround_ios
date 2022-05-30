//
//  JoinVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/12.
//

import Foundation
import UIKit

class JoinVC: BaseViewController, DialogPopupViewDelegate, UIViewControllerTransitioningDelegate{
 
  @IBOutlet weak var IdTextField: UITextField!
  @IBOutlet weak var PwdTextField: UITextField!
  @IBOutlet weak var PwdTextFieldConfirm: UITextField!
  @IBOutlet weak var PhoneTextField: UITextField!
  @IBOutlet weak var SmsTextField: UITextField!
  @IBOutlet weak var NicknameTextField: UITextField!
  
  var checkId : Bool = false

  
  func idcheck(){
    APIProvider.shared.authAPI.rx.request(.isExistLoginId(email: IdTextField.text!))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.dismissHUD()
        if(value.message == "아이디가 없습니다."){
          self.callOkActionMSGDialog(message: "사용 가능한 아이디입니다.") {
            self.checkId = true
          }
        }else{
          self.callOkActionMSGDialog(message: "중복된 아이디입니다.") {
          }
        }
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  func smsSend(){
    let param = SendCodeRequest(tel: PhoneTextField.text!, diff: .join)
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
//    let param = CheckphoneCodeRequest()
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
  
  func Register(){
    if NicknameTextField.text!.isEmpty{
      callMSGDialog(message: "아이디를 입력해주세요.")
    }else if !checkId {
      callMSGDialog(message: "아이디 중복확인을 해주세요..")
    }else if PwdTextField.text!.isEmpty{
      callMSGDialog(message: "비밀번호를 입력해주세요.")
    }else if PwdTextFieldConfirm.text!.isEmpty{
      callMSGDialog(message: "비밀번호 확인을 입력해주세요.")
    }else if PwdTextField.text != PwdTextFieldConfirm.text{
      callMSGDialog(message: "비밀번호가 일치하지않습니다.")
    }else if !PwdTextField.text!.isPasswordValidate(){
      callMSGDialog(message: "비밀번호 설정 규칙에 맞춰 입력하세요.")
    }else if PhoneTextField.text!.isEmpty{
      callMSGDialog(message: "전화번호를 입력해주세요.")
    }else if SmsTextField.text!.isEmpty{
      callMSGDialog(message: "인증번호를 입력해주세요.")
    }else{
      let param = JoinRequest(loginId: IdTextField.text!, password: PwdTextField.text!, tel: PhoneTextField.text!, name: NicknameTextField.text!)
      APIProvider.shared.authAPI.rx.request(.join(param: param))
        .filterSuccessfulStatusCodes()
        .map(DefaultResponse.self)
        .subscribe(onSuccess: { value in
          self.dismissHUD()
            let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "JoinOkVC") as! JoinOkVC
            self.navigationController?.pushViewController(vc, animated: true)
        }, onError: { error in
          self.dismissHUD()
        })
        .disposed(by: disposeBag)
    }
  }
  
  func dialogOkEvent() {
    showDialogPopupView()
  }
  
  @objc func showDialogPopupView() {
    let vc = DialogPopupView()
    vc.modalPresentationStyle = .custom
    vc.transitioningDelegate = self
    vc.delegate = self
    vc.titleString = "인증번호는 1분에 한 번만 가능합니다."
    vc.contentString = "잠시만 기다려 주세요."
    vc.okbuttonTitle = "확인"
    self.present(vc, animated: true, completion: nil)
  }
  
  @IBAction func tapIdCheck(_ sender: Any) {
    idcheck()
  }
  @IBAction func tapSmsSend(_ sender: Any) {
    smsSend()
  }
  @IBAction func tapSmsConfirm(_ sender: Any) {
    smsCheck()
  }
  @IBAction func tapRegist(_ sender: Any) {
    Register()
  }
}
