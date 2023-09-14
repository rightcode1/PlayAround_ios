//
//  FoodDetailMenuPopupVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/08.
//

import UIKit
import RxSwift

protocol FoodDetailMenuDelegate : AnyObject {
  func shareFood()
  
  func updateFood()
  
  func updateFoodStatus()
  
  func removeFood()
  
  func reportFood()
}

class FoodDetailMenuPopupVC: BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var modifyView: UIView!
  @IBOutlet weak var finishSaleView: UIView!
  @IBOutlet weak var removeView: UIView!
  
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var modifyButton: UIButton!
  @IBOutlet weak var finishButton: UIButton!
  @IBOutlet weak var removeButton: UIButton!
  @IBOutlet weak var reportButton: UIButton!
  
  weak var delegate: FoodDetailMenuDelegate?
  let isMine = BehaviorSubject<Bool>(value: false)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bindInput()
    bindOutput()
  }
  
  static func viewController() -> FoodDetailMenuPopupVC {
    let viewController = FoodDetailMenuPopupVC.viewController(storyBoardName: "Food")
    return viewController
  }
  
  func bindInput() {
    shareButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.shareFood()
      })
      .disposed(by: disposeBag)
    
    modifyButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.updateFood()
      })
      .disposed(by: disposeBag)
    
    finishButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.updateFoodStatus()
      })
      .disposed(by: disposeBag)
    
    removeButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.removeFood()
      })
      .disposed(by: disposeBag)
    
    reportButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.backPress()
        self.delegate?.reportFood()
      })
      .disposed(by: disposeBag)
  }
  
  func bindOutput() {
    isMine
      .bind(onNext: { [weak self] isMine in
        guard let self = self else { return }
        self.modifyView.isHidden = !isMine
        self.finishSaleView.isHidden = !isMine
        self.removeView.isHidden = !isMine
      })
      .disposed(by: disposeBag)
  }
  
}
