//
//  CommunityDetailMenuPopupVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/07/13.
//

import Foundation
import UIKit
import RxSwift

protocol CommunityDetailMenuDelegate {
  func shareCommunity()
  
  func updateCommunity()
  
  func removeCommunity()
  
}

class CommunityDetailMenuPopupVC: BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var modifyView: UIView!
  @IBOutlet weak var removeView: UIView!
  
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var modifyButton: UIButton!
  @IBOutlet weak var removeButton: UIButton!
  
  var delegate: CommunityDetailMenuDelegate?
  let isMine = BehaviorSubject<Bool>(value: false)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bindInput()
    bindOutput()
  }
  
  static func viewController() -> CommunityDetailMenuPopupVC {
    let viewController = CommunityDetailMenuPopupVC.viewController(storyBoardName: "Community")
    return viewController
  }
  
  func bindInput() {
    shareButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.shareCommunity()
      })
      .disposed(by: disposeBag)
    
    modifyButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.updateCommunity()
      })
      .disposed(by: disposeBag)
    
    removeButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.removeCommunity()
      })
      .disposed(by: disposeBag)
  }
  
  func bindOutput() {
    isMine
      .bind(onNext: { [weak self] isMine in
        guard let self = self else { return }
        self.modifyView.isHidden = !isMine
        self.removeView.isHidden = !isMine
      })
      .disposed(by: disposeBag)
  }
  
}
