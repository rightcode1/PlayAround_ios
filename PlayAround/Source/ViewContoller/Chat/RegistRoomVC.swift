//
//  RegistRoom.swift
//  PlayAround
//
//  Created by 이남기 on 2022/12/01.
//

import Foundation
import UIKit

class RegistRoomVC:BaseViewController,ViewControllerFromStoryboard{
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var tapRegister: UIButton!
    
    var communityId: Int = 0
    
    static func viewController() -> RegistRoomVC {
      let viewController = RegistRoomVC.viewController(storyBoardName: "Chat")
      return viewController
    }
    
    override func viewDidLoad() {
        initrx()
    }
    
    func initrx(){
        tapRegister.rx.tap
          .bind(onNext: { [weak self] in
            guard let self = self else { return }
              self.startChat()
          })
          .disposed(by: disposeBag)
    }
    func startChat() {
        let param = RegistChatRoomRequest(title: titleTextField.text, communityId: communityId)
      APIProvider.shared.chatAPI.rx.request(.roomRegister(param: param))
        .filterSuccessfulStatusCodes()
        .map(RegistChatRoomResponse.self)
        .subscribe(onSuccess: { value in
          let vc = ChatVC.viewController()
            vc.communityId = self.communityId
            vc.communityTitle = self.titleTextField.text ?? ""
            vc.chatRoomId = value.data.id
            vc.isregistCommunity = true
          self.navigationController?.pushViewController(vc, animated: true)
        }, onError: { error in
        })
        .disposed(by: disposeBag)
    }
    
}
