//
//  BaseViewController.swift
//  cheorwonHotPlace
//
//  Created by hoon Kim on 28/01/2020.
//  Copyright © 2020 hoon Kim. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxGesture
import Alamofire
import SwiftyJSON
import Kingfisher
import UserNotifications

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
  // MARK: Rx
  
  var appColor = AppColor()
  
  var disposeBag = DisposeBag()
  
  @IBInspectable var localizedText: String = "" {
    didSet {
      if localizedText.count > 0 {
#if TARGET_INTERFACE_BUILDER
        var bundle = NSBundle(forClass: type(of: self))
        self.title = bundle.localizedStringForKey(self.localizedText, value:"", table: nil)
#else
        self.title = NSLocalizedString(self.localizedText, comment:"");
#endif
      }
    }
  }
  @objc func MyTapMethod(sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
  func backTwo() {
    let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
    self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.clipsToBounds = true
    
    //    let notificationCenter = NotificationCenter.default
    //    notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    //
    //    // EnterForeground -> applicationWillEnterForeground -> applcation(_: open url: options:) -> applicationDidBecomeActive 순서로 진행 됨
    //    notificationCenter.addObserver(self, selector: #selector(backgroundMovedToApp), name: UIApplication.didBecomeActiveNotification, object: nil)
  }
  
  //  @objc func appMovedToBackground() {
  //    print("App moved to background!")
  //  }
  //
  //  @objc func backgroundMovedToApp() {
  //    print("Background moved to app!")
  ////    shareEvents()
  //  }
  
  func shareEvents() {
    //    if shareFeedId != 0 {
    //      let vc = UIStoryboard.init(name: "Sns", bundle: nil).instantiateViewController(withIdentifier: "feedList") as! FeedListViewController
    //      vc.shareId = shareFeedId
    //      navigationController?.pushViewController(vc, animated: true)
    //      shareFeedId = 0
    //    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func userInfo(result: @escaping (UserInfoResponse) -> Void) {
    let param = UserInfoRequest()
    APIProvider.shared.userAPI.rx.request(.userInfo(param: param))
      .filterSuccessfulStatusCodes()
      .map(UserInfoResponse.self)
      .subscribe(onSuccess: { response in
        DataHelper.set(response.data.id, forKey: .userAppId)
        result(response)
      }, onError: { error in
        print("error StatusCode: \(APIProvider.shared.getErrorStatusCode(error))")
        let backendError = (error as? MoyaError)?.backendError
        print("backendError: \(backendError?.message ?? "")")
      })
      .disposed(by: disposeBag)
  }
  
  func foodLevelImage(level: Int) -> UIImage {
    return UIImage(named: "foodLevel\(level)") ?? UIImage()
  }
  
  func usedLevelImage(level: Int) -> UIImage {
    return UIImage(named: "usedLevel\(level)") ?? UIImage()
  }
  
  func clearImageCache() {
    let cache = ImageCache.default
    cache.clearMemoryCache()
    cache.clearCache { print("reset image cache") }
    
    cache.cleanExpiredMemoryCache()
    cache.clearDiskCache { print("reset image cache") }
  }
  
}
