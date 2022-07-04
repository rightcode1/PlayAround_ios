//
//  SplashVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/11.
//

import UIKit
import TAKUUID

class SplashVC: BaseViewController, ViewControllerFromStoryboard {
  
  var version: String? {
    guard let dictionary = Bundle.main.infoDictionary,
          let build = dictionary["CFBundleVersion"] as? String else {return nil}
    return build
  }
  
  override func viewDidLoad() {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
      self.checkVersion()
    }
  }
  
  static func viewController() -> SplashVC {
    let viewController = SplashVC.viewController(storyBoardName: "Splash")
    return viewController
  }
  
  func login() {
    TAKUUIDStorage.sharedInstance().migrate()
    let uuid = TAKUUIDStorage.sharedInstance().findOrCreate() ?? ""
    self.showHUD()
    let param = LoginRequest(loginId:  DataHelperTool.userId ?? "",password: DataHelperTool.userPw ?? "",deviceId: uuid)
    APIProvider.shared.authAPI.rx.request(.login(param: param))
      .filterSuccessfulStatusCodes()
      .map(LoginResponse.self)
      .subscribe(onSuccess: { value in
        DataHelper<String>.remove(forKey: .token)
        DataHelper.set("bearer \(value.token)", forKey: .token)
        DataHelper.set("\(value.token)", forKey: .chatToken)
      
        self.dismissHUD()
        self.goMain()
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
