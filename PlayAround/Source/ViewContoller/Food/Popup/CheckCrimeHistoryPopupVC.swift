//
//  CheckCrimeHistoryPopupVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/08.
//

import UIKit

protocol CheckCrimeHistoryDelegate {
  func moveToCheckCheatWithWeb(urlString: String)
}

class CheckCrimeHistoryPopupVC: BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var policeButton: UIButton!
  @IBOutlet weak var thecheatButton: UIButton!
  
  var delegate: CheckCrimeHistoryDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bindInput()
  }
  
  static func viewController() -> CheckCrimeHistoryPopupVC {
    let viewController = CheckCrimeHistoryPopupVC.viewController(storyBoardName: "Food")
    return viewController
  }
  
  func bindInput() {
    policeButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.moveToCheckCheatWithWeb(urlString: "https://cyberbureau.police.go.kr/prevention/sub7.jsp?mid=020600")
      })
      .disposed(by: disposeBag)
    
    thecheatButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.moveToCheckCheatWithWeb(urlString: "https://thecheat.co.kr/rb/?mod=_search")
      })
      .disposed(by: disposeBag)
  }
  
}
