//
//  UpdateProfileVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/20.
//

import UIKit

class UpdateProfileVC: BaseViewController {
  
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var userLoginIdTextField: UITextField!
  @IBOutlet weak var userTelTextField: UITextField!
  
  @IBOutlet weak var updateButton: UIBarButtonItem!
  
  var userId: Int = -1
  
  var updateImage: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindInput() 
    initUserInfo()
  }
  
  func initUserInfo() {
    userInfo() { result in
      self.view.endEditing(true)
      self.userId = result.data.id
      if result.data.thumbnail == nil {
        self.userImageView.image = UIImage(named: "defaultProfileImage")
      } else {
        self.userImageView.kf.setImage(with: URL(string: result.data.thumbnail ?? ""))
      }
      self.userNameTextField.text = result.data.name
      self.userLoginIdTextField.text = result.data.loginId
      self.userTelTextField.text = result.data.tel
    }
  }
  
  func updateUserInfo() {
    self.showHUD()
    let param = UpdateUserInfoRequest(name: userNameTextField.text!)
    
    APIProvider.shared.userAPI.rx.request(.userUpdate(param: param))
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        self.registUserProfile(success: {
          self.dismissHUD()
          self.showToast(message: "유저 정보가 수정되었습니다.")
          self.initUserInfo()
        })
      }, onError: { error in
        self.dismissHUD()
        self.showToast(message: error.localizedDescription)
      })
      .disposed(by: disposeBag)
  }
  
  func registUserProfile(success: @escaping () -> Void) {
    if updateImage != nil {
      APIProvider.shared.userAPI.rx.request(.userFileRegister(image: updateImage!))
        .filterSuccessfulStatusCodes()
        .subscribe(onSuccess: { response in
          success()
        }, onError: { error in
          success()
        })
        .disposed(by: disposeBag)
    } else {
      success()
    }
  }
  
  func bindInput() {
    userImageView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        UIImagePickerController.showGallery(self, withIdentifier: "thumbnail")
      })
      .disposed(by: disposeBag)
    
    updateButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if !self.userNameTextField.text!.isEmpty {
          self.updateUserInfo()
        }
      })
      .disposed(by: disposeBag)
  }
}

extension UpdateProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true) {
      let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
      
      self.updateImage = image.resizeToWidth(newWidth: 500)
      self.userImageView.image = image.resizeToWidth(newWidth: 500)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {}
  }
}
