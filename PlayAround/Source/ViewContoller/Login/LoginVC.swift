//
//  LoginVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/11.
//

import Foundation
import UIKit
import TAKUUID
import Gifu

class LoginVC: BaseViewController{
  @IBOutlet weak var idTextField: UITextField!
  @IBOutlet weak var pwdTextField: UITextField!
  @IBOutlet weak var loginSplash: GIFImageView!
  @IBOutlet weak var backView: UIView!
  
  override func viewDidLoad() {
    loginSplash.animate(withGIFNamed:"login")
    
//    backView.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 0, y: 1.5, blur: 5, spread: 0)
    backView?.layer.cornerRadius  = 10
    backView?.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
  }
  
  override func viewWillAppear(_ animated: Bool) {
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
        if(value.statusCode <= 202){
          DataHelper.set("bearer \(value.token)", forKey: .token)
          DataHelper.set("\(value.token)", forKey: .chatToken)
          DataHelper.set(self.idTextField.text!, forKey: .userId)
          DataHelper.set(self.pwdTextField.text!, forKey: .userPw)
          if DataHelperTool.villageName != nil{
            self.goMain()
          }else{
            let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "VillageListVC") as! VillageListVC
            vc.viewController = "login"
            self.navigationController?.pushViewController(vc, animated: true)
          }
        }
        self.dismissHUD()
      }, onError: { error in
        self.callOkActionMSGDialog(message: "로그인 정보를 확인해주세요.") {
        }
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
