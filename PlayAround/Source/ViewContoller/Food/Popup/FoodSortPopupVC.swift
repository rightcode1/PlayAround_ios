//
//  FoodSortPopupVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/08.
//

import UIKit

enum FoodSort: String, Codable {
  case 최신순
  case 추천순
  case 인기순
//  case 가격낮은순
//  case 가격높은순
}

protocol FoodSortDelegate {
  func setFoodSort(sort: FoodSort)
}

class FoodSortPopupVC: BaseViewController, ViewControllerFromStoryboard {
  
  @IBOutlet weak var latestButton: UIButton!
  @IBOutlet weak var recommendedButton: UIButton!
  @IBOutlet weak var popularityButton: UIButton!
  @IBOutlet weak var cheapButton: UIButton!
  @IBOutlet weak var expensiveButton: UIButton!
  
  var delegate: FoodSortDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bindInput()
  }
  
  static func viewController() -> FoodSortPopupVC {
    let viewController = FoodSortPopupVC.viewController(storyBoardName: "Food")
    return viewController
  }
  
  func bindInput() {
    latestButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.setFoodSort(sort: .최신순)
      })
      .disposed(by: disposeBag)
    
    recommendedButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.setFoodSort(sort: .추천순)
      })
      .disposed(by: disposeBag)
    
    popularityButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.setFoodSort(sort: .인기순)
      })
      .disposed(by: disposeBag)
    cheapButton.isHidden = true
    expensiveButton.isHidden = true
//
//    cheapButton.rx.tap
//      .bind(onNext: { [weak self] in
//        guard let self = self else { return }
//        self.backPress()
//        self.delegate?.setFoodSort(sort: .가격낮은순)
//      })
//      .disposed(by: disposeBag)
//
//    expensiveButton.rx.tap
//      .bind(onNext: { [weak self] in
//        guard let self = self else { return }
//        self.backPress()
//        self.delegate?.setFoodSort(sort: .가격높은순)
//      })
//      .disposed(by: disposeBag)
  }
}
