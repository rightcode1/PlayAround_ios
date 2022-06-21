//
//  UIImagePickerController+Extension.swift
//  ginger9
//
//  Created by jason on 2021/05/24.
//

import Foundation
import UIKit

extension UIImagePickerController {

  class func showCamera(_ viewController: (UIImagePickerControllerDelegate & UINavigationControllerDelegate & UIViewController),
                        withIdentifier identifier: String? = nil,
                        cameraDevice: UIImagePickerController.CameraDevice = .rear){
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = viewController
    imagePicker.accessibilityValue = identifier
    imagePicker.allowsEditing = false
    imagePicker.sourceType = .camera
    imagePicker.cameraCaptureMode = .photo
    imagePicker.modalPresentationStyle = .overCurrentContext
    imagePicker.cameraDevice = cameraDevice
    viewController.present(imagePicker, animated : true, completion : nil)
  }

  class func showGallery(_ viewController: (UIImagePickerControllerDelegate & UINavigationControllerDelegate & UIViewController),
                         withIdentifier identifier: String? = nil){
    viewController.showHUD()
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = viewController
    imagePicker.accessibilityValue = identifier
    imagePicker.allowsEditing = false
    imagePicker.sourceType = .photoLibrary
    viewController.present(imagePicker, animated : true, completion : nil)
    viewController.dismissHUD()
  }
}
