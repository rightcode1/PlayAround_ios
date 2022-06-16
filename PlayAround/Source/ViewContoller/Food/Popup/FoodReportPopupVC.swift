//
//  FoodReportPopupVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/08.
//

import UIKit

protocol FoodReportDelegate {
  func finishFoodReport()
}

class FoodReportPopupVC: BaseViewController, ViewControllerFromStoryboard, UITextViewDelegate {
  @IBOutlet weak var contentTextView: UITextView! {
    didSet {
      contentTextView.delegate = self
    }
  }
  @IBOutlet weak var contentTextViewPlaceHolder: UILabel!
  @IBOutlet weak var reportButton: UIButton!
  
  var delegate: FoodReportDelegate?
  var foodId: Int?
  var usedId: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindInput()
    
  }
  
  static func viewController() -> FoodReportPopupVC {
    let viewController = FoodReportPopupVC.viewController(storyBoardName: "Food")
    return viewController
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if (text == "\n") {
      textView.resignFirstResponder()
    } else {
    }
    return true
  }
  
  func registReport() {
    let param = RegistReportRequest(content: contentTextView.text!, foodId: foodId, usedId: usedId)
    APIProvider.shared.reportAPI.rx.request(.register(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        print("?????????????????? 뭐야 이거")
        self.backPress()
        self.delegate?.finishFoodReport()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func bindInput() {
    reportButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if !self.contentTextView.text!.isEmpty {
          self.registReport()
        }
      })
      .disposed(by: disposeBag)
    
    contentTextView.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        self?.contentTextViewPlaceHolder.isHidden = !text.isEmpty
      })
      .disposed(by: disposeBag)
  }
  
}
