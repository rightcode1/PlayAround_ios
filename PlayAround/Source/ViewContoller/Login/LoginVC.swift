//
//  LoginVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/11.
//

import Foundation
import UIKit
import TAKUUID

class LoginVC: BaseViewController{
  @IBOutlet weak var idTextField: UITextField!
  
  @IBOutlet weak var pwdTextField: UITextField!
  
  override func viewDidLoad() {
    navigationController?.isNavigationBarHidden = true
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
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
        self.dismissHUD()
        
        if(value.statusCode <= 202){
          DataHelper.set("bearer \(value.token)", forKey: .token)
          DataHelper.set("\(value.token)", forKey: .chatToken)
          DataHelper.set(self.idTextField.text!, forKey: .userId)
          DataHelper.set(self.pwdTextField.text!, forKey: .userPw)
          
          self.goMain()
        }
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  @IBAction func tapLogin(_ sender: Any) {
    login()
  }
  
  @IBAction func tapRegist(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "JoinVC") as! JoinVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func tapFindID(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "FindIdVC") as! FindIdVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func tapFindPwd(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "FindPwdVC") as! FindPwdVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
