//
//  SplashVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/11.
//

import UIKit


class SplashVC :BaseViewController{
  var version: String? {
    guard let dictionary = Bundle.main.infoDictionary,
          let build = dictionary["CFBundleVersion"] as? String else {return nil}
    return build
  }
    override func viewDidLoad() {
      print("======token:\(DataHelperTool.token)")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.checkVersion()
        }
    }
    func login() {
      self.showHUD()
      let param = LoginRequest(loginId:  DataHelperTool.userId ?? "",password: DataHelperTool.userPw ?? "")

      APIProvider.shared.authAPI.rx.request(.login(param: param))
        .filterSuccessfulStatusCodes()
        .map(LoginResponse.self)
        .subscribe(onSuccess: { value in
          DataHelper<String>.remove(forKey: .token)
          DataHelper.set("bearer \(value.token)", forKey: .token)
          self.goMain()
          self.dismissHUD()
        }, onError: { error in
            let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginNC")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
          self.dismissHUD()
        })
        .disposed(by: disposeBag)
    }
    
    func checkVersion() {
      APIProvider.shared.authAPI.rx.request(.versionCheck)
        .filterSuccessfulStatusCodes()
        .map(VersionResponse.self)
        .subscribe(onSuccess: { value in
            let versionNumber: Int = Int(self.version!) ?? 0
            if versionNumber < value.data.ios {
              self.performSegue(withIdentifier: "update", sender: nil)
            } else {
              if(DataHelperTool.token != nil){
                self.login()
              }else{
                let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginNC")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
              }
            }
          self.dismissHUD()
        }, onError: { error in
          self.dismissHUD()
        })
        .disposed(by: disposeBag)
    }
}
