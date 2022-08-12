//
//  CommunityPopUpVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/07/13.
//

import Foundation
import UIKit

enum CommunitySort: String, Codable {
  case 최신순
  case 인기순
}

protocol CommunitySortDelegate {
  func setCommunitySort(sort: CommunitySort)
}

class CommunitySortPopupVC: BaseViewController, ViewControllerFromStoryboard {
  
  @IBOutlet weak var latestButton: UIButton!
  @IBOutlet weak var popularityButton: UIButton!
  
  var delegate: CommunitySortDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bindInput()
  }
  
  static func viewController() -> CommunitySortPopupVC {
    let viewController = CommunitySortPopupVC.viewController(storyBoardName: "Community")
    return viewController
  }
  
  func bindInput() {
    latestButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.setCommunitySort(sort: .최신순)
      })
      .disposed(by: disposeBag)
    
    popularityButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.setCommunitySort(sort: .인기순)
      })
      .disposed(by: disposeBag)
  }
}
