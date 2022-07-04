//
//  UpdateProfileVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/20.
//

import UIKit

enum UpdateProfilePopupDiff: String {
  case logout
  case withdrawal
}

class UpdateProfileVC: BaseViewController {
  
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var userLoginIdTextField: UITextField!
  @IBOutlet weak var userTelTextField: UITextField!
  
  @IBOutlet weak var updateButton: UIBarButtonItem!
  
  @IBOutlet weak var logoutButton: UIButton!
  @IBOutlet weak var withdrawalButton: UIButton!
  
  var userId: Int = -1
  
  var updateImage: UIImage?
  
  var popupDiff: UpdateProfilePopupDiff = .logout
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindInput() 
    initUserInfo()
  }
  
  func showDialogPopupView(with diff: UpdateProfilePopupDiff) {
    popupDiff = diff
    
    let vc = DialogPopupView()
    vc.modalPresentationStyle = .custom
    vc.transitioningDelegate = self
    vc.delegate = self
    vc.titleString = diff == .logout ? "로그아웃" : "탈퇴하기"
    vc.contentString = diff == .logout ? "플레이어라운드를 로그아웃 하시겠습니까?" : "플레이 어라운드를 탈퇴하시겠습니까?\n기록된 정보들은 모두 사라집니다."
    vc.okbuttonTitle = diff == .logout ? "로그아웃" : "회원탈퇴"
    vc.cancelButtonTitle = "취소"
    self.present(vc, animated: true, completion: nil)
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
  
  func logout() {
    userLogout() { result in
      if result.statusCode == 200 {
        DataHelper<Any>.clearAll()
        let vc = SplashVC.viewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
      }
    }
  }
  
  func withdrawal() {
    APIProvider.shared.userAPI.rx.request(.userWithDrawal)
      .filterSuccessfulStatusCodes()
      .subscribe(onSuccess: { response in
        DataHelper<Any>.clearAll()
        self.okActionAlert(message: "회원탈퇴가 완료되었습니다.") {
          let vc = SplashVC.viewController()
          vc.modalPresentationStyle = .fullScreen
          self.present(vc, animated: true, completion: nil)
        }
      }, onError: { error in
        self.dismissHUD()
        self.showToast(message: error.localizedDescription)
      })
      .disposed(by: disposeBag)
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
    
    logoutButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.showDialogPopupView(with: .logout)
      })
      .disposed(by: disposeBag)
    
    withdrawalButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.showDialogPopupView(with: .withdrawal)
      })
      .disposed(by: disposeBag)
  }
}

extension UpdateProfileVC: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    PresentationController(presentedViewController: presented, presenting: presenting)
  }
}

extension UpdateProfileVC: DialogPopupViewDelegate {
  func dialogOkEvent() {
    switch popupDiff {
    case .logout:
      logout()
    case .withdrawal:
      withdrawal()
    }
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
