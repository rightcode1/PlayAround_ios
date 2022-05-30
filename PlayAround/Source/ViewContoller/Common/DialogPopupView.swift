//
//  DialogPopupView.swift
//  camver
//
//  Created by hoon Kim on 2022/01/18.
//

import UIKit

protocol DialogPopupViewDelegate {
  func dialogOkEvent()
}

protocol DialogPopupViewRemoveDelegate {
  func dialogRemoveEvent(isRemove: Bool)
}

class DialogPopupView: UIViewController {
  
  @IBOutlet weak var backView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var okButton: UIButton!
  
  var hasSetPointOrigin = false
  var pointOrigin: CGPoint?
  
  var delegate: DialogPopupViewDelegate?
  var removeDelegate: DialogPopupViewRemoveDelegate?
  
  var titleString: String?
  var contentString: String?
  
  var cancelButtonTitle: String?
  var okbuttonTitle: String?
  
  var isRemove: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
    view.addGestureRecognizer(panGesture)
    
    backView.roundCorners([.topLeft, .topRight], radius: 25)
    initContents()
  }
  
  override func viewDidLayoutSubviews() {
    if !hasSetPointOrigin {
      hasSetPointOrigin = true
      pointOrigin = self.view.frame.origin
    }
  }
  
  @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view)
    
    // Not allowing the user to drag the view upward
    guard translation.y >= 0 else { return }
    
    // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
    view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
    
    if sender.state == .ended {
      let dragVelocity = sender.velocity(in: view)
      if dragVelocity.y >= 1200 {
        self.dismiss(animated: true, completion: nil)
      } else {
        // Set back to original position of the view controller
        UIView.animate(withDuration: 0.3) {
          self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 172)
        }
      }
    }
  }
  
  func initContents() {
    titleLabel.text = titleString
    contentLabel.text = contentString
    
    cancelButton.isHidden = cancelButtonTitle == nil
    
    cancelButton.setTitle(cancelButtonTitle ?? "닫기", for: .normal)
    okButton.setTitle(okbuttonTitle ?? "확인", for: .normal)
  }
  
  @IBAction func tapBack(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
    if isRemove {
      removeDelegate?.dialogRemoveEvent(isRemove: false)
    }
  }
  
  @IBAction func tapOk(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
    if isRemove {
      removeDelegate?.dialogRemoveEvent(isRemove: true)
    } else {
      delegate?.dialogOkEvent()
    }
  }
  
}
