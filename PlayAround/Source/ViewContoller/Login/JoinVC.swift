//
//  JoinVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/12.
//

import Foundation
import UIKit
import TAKUUID

class JoinVC: BaseViewController, DialogPopupViewDelegate, UIViewControllerTransitioningDelegate {
  
  @IBOutlet weak var idTextField: UITextField!
  @IBOutlet weak var pwdTextField: UITextField!
  @IBOutlet weak var pwdTextFieldConfirm: UITextField!
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var smsTextField: UITextField!
  @IBOutlet weak var nicknameTextField: UITextField!
  
  var checkId : Bool = false
  
  func idcheck(){
    if idTextField.text!.isEmpty{
      callMSGDialog(message: "아이디를 입력해주세요.")
    }else{
      APIProvider.shared.authAPI.rx.request(.isExistLoginId(email: idTextField.text!))
        .filterSuccessfulStatusCodes()
        .map(DefaultResponse.self)
        .subscribe(onSuccess: { value in
          self.dismissHUD()
          self.callOkActionMSGDialog(message: "사용 가능한 아이디입니다.") {
            self.checkId = true
          }
        }, onError: { error in
          self.dismissHUD()
          self.callOkActionMSGDialog(message: "중복된 아이디입니다.") {
          }
        })
        .disposed(by: disposeBag)
    }
  }
  
  func smsSend(){
    let param = SendCodeRequest(tel: phoneTextField.text!, diff: .join)
    APIProvider.shared.authAPI.rx.request(.sendCode(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "인증번호를 전송했습니다.") {
        }
      }, onError: { error in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "중복된 휴대폰번호입니다.") {
        }
      })
      .disposed(by: disposeBag)
  }
  
  func smsCheck(){
    //    let param = CheckphoneCodeRequest()
    APIProvider.shared.authAPI.rx.request(.confirm(tel: phoneTextField.text!, confirm: smsTextField.text!))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "인증되었습니다.") {
        }
      }, onError: { error in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "인증번호를 확인해주세요.") {
        }
      })
      .disposed(by: disposeBag)
  }
  
  func Register(){
    if idTextField.text!.isEmpty{
      callMSGDialog(message: "아이디를 입력해주세요.")
    }else if !checkId {
      callMSGDialog(message: "아이디 중복확인을 해주세요..")
    }else if pwdTextField.text!.isEmpty{
      callMSGDialog(message: "비밀번호를 입력해주세요.")
    }else if pwdTextFieldConfirm.text!.isEmpty{
      callMSGDialog(message: "비밀번호 확인을 입력해주세요.")
    }else if pwdTextField.text != pwdTextFieldConfirm.text{
      callMSGDialog(message: "비밀번호가 일치하지않습니다.")
    }else if !pwdTextField.text!.isPasswordValidate(){
      callMSGDialog(message: "비밀번호 설정 규칙에 맞춰 입력하세요.")
    }else if phoneTextField.text!.isEmpty{
      callMSGDialog(message: "전화번호를 입력해주세요.")
    }else if smsTextField.text!.isEmpty{
      callMSGDialog(message: "인증번호를 입력해주세요.")
    }else if nicknameTextField.text!.isEmpty{
      callMSGDialog(message: "닉네임을 입력해주세요.")
    }else{
      let param = JoinRequest(loginId: idTextField.text!, password: pwdTextField.text!, tel: phoneTextField.text!, name: nicknameTextField.text!)
      APIProvider.shared.authAPI.rx.request(.join(param: param))
        .filterSuccessfulStatusCodes()
        .map(DefaultResponse.self)
        .subscribe(onSuccess: { value in
          self.dismissHUD()
          self.login()
        }, onError: { error in
          self.dismissHUD()
        })
        .disposed(by: disposeBag)
    }
  }
  func login() {
    TAKUUIDStorage.sharedInstance().migrate()
    let uuid = TAKUUIDStorage.sharedInstance().findOrCreate() ?? ""
    self.showHUD()
    let param = LoginRequest(loginId: idTextField.text!, password: pwdTextField.text!, deviceId: uuid)
    APIProvider.shared.authAPI.rx.request(.login(param: param))
      .filterSuccessfulStatusCodes()
      .map(LoginResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 202){
          DataHelper.set("bearer \(value.token)", forKey: .token)
          DataHelper.set("\(value.token)", forKey: .chatToken)
          DataHelper.set(self.idTextField.text!, forKey: .userId)
          DataHelper.set(self.pwdTextField.text!, forKey: .userPw)
          
          let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "JoinOkVC") as! JoinOkVC
          self.navigationController?.pushViewController(vc, animated: true)
        }
        self.dismissHUD()
      }, onError: { error in
        self.callOkActionMSGDialog(message: "로그인 정보를 확인해주세요.") {
        }
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
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
