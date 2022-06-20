//
//  RegistInquiryVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/20.
//

import UIKit

class RegistInquiryVC: BaseViewController {
  
  @IBOutlet weak var titleTextField: UITextField!
  
  @IBOutlet weak var contentTextView: UITextView!
  @IBOutlet weak var contentTextViewPlaceHolder: UILabel!
  
  @IBOutlet weak var registButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bindInput()
  }
  
  func regist() {
    guard !titleTextField.text!.isEmpty else {
      showToast(message: "제목을 입력해주세요.")
      return
    }
    
    guard !contentTextView.text!.isEmpty else {
      showToast(message: "내용을 입력해주세요.")
      return
    }
    
    let param = RegistInquiryRequest(
      title: titleTextField.text!,
      content: contentTextView.text!
    )
    
    showHUD()
    
    APIProvider.shared.inquiryAPI.rx.request(.register(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { response in
        self.dismissHUD()
        self.callOkActionMSGDialog(message: "문의가 등록되었습니다.") {
          self.backPress()
        }
      }, onError: { error in
        self.dismissHUD()
        self.callMSGDialog(message: "오류가 발생하였습니다")
      })
      .disposed(by: disposeBag)
  }
  
  
  func bindInput() {
    contentTextView.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        self?.contentTextViewPlaceHolder.isHidden = !text.isEmpty
      })
      .disposed(by: disposeBag)
    
    registButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.regist()
      })
      .disposed(by: disposeBag)
  }
  
}
