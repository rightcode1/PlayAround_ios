//
//  VillageDialogVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/07/27.
//

import Foundation
import UIKit
import RxSwift

protocol villageProtocol{
  func villageState(state:String,indexPath: IndexPath)
}

class VillageDialogVC: BaseViewController {
  
  
  @IBOutlet var backgroundView: UIView!
  @IBOutlet weak var backView: UIView!
  @IBOutlet weak var titleLabel: UILabel!

  @IBOutlet weak var villageDelete: UIView!
  
  var hasSetPointOrigin = false
  var pointOrigin: CGPoint?
  var indexPath: IndexPath = []
  
  var delegate: villageProtocol?
  
  var titleString: String = ""
  var contentString: String?
  
  var cancelButtonTitle: String?
  var okbuttonTitle: String?
  
  var isRemove: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initContents()
  }
  
  func initrx(){
    villageDelete.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.delegate?.villageState(state: "삭제",indexPath: self.indexPath)
      })
      .disposed(by: disposeBag)
  }
  override func viewDidLayoutSubviews() {
    if !hasSetPointOrigin {
      hasSetPointOrigin = true
      pointOrigin = self.view.frame.origin
    }
  }
  
  func initContents() {
    backgroundView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
    titleLabel.text = "\(titleString)\n 동네로 이동하시겠습니까?"
    backView.roundCorners([.topLeft, .topRight], radius: 25)
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
    view.addGestureRecognizer(panGesture)
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
  
  @IBAction func tapBack(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func tapOk(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
    delegate?.villageState(state: "이동",indexPath: self.indexPath)
  }
  
}
