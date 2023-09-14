//
//  FoodUserListVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/12/29.
//

import Foundation
import UIKit
import RxSwift


class FoodUserListVC:BaseViewController,ViewControllerFromStoryboard{
    
    
    @IBOutlet weak var mainTableView: UITableView!
    
    static func viewController() -> FoodUserListVC {
      let viewController = FoodUserListVC.viewController(storyBoardName: "Food")
      return viewController
    }
    
    var foodId: Int = 0
    var foodUserList: [User] = []
    
    override func viewWillAppear(_ animated: Bool) {
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
    func startChat(foodUserId: Int) {
      let param = RegistChatRoomRequest(foodId: foodId, userId: foodUserId)
      APIProvider.shared.chatAPI.rx.request(.roomRegister(param: param))
        .filterSuccessfulStatusCodes()
        .map(RegistChatRoomResponse.self)
        .subscribe(onSuccess: { value in
          
          let vc = ChatVC.viewController()
          vc.foodId = self.foodId
          vc.chatRoomId = value.data.id
          self.navigationController?.pushViewController(vc, animated: true)
        }, onError: { error in
        })
        .disposed(by: disposeBag)
    }
    func removeFoodUser(foodUserId: Int,index: Int) {
        let param = RemoveFoodUserRequest(foodId: foodId, userId: foodUserId)
      APIProvider.shared.foodAPI.rx.request(.foodremove(param: param))
        .filterSuccessfulStatusCodes()
        .map(DefaultResponse.self)
        .subscribe(onSuccess: { value in
            self.callOkActionMSGDialog(message: "삭제되었습니다.") {
            }
            self.foodUserList.remove(at: index)
            self.mainTableView.reloadData()
        }, onError: { error in
        })
        .disposed(by: disposeBag)
    }
}
extension FoodUserListVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return foodUserList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let dict = foodUserList[indexPath.row]
    let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FoodUserCell
      cell.delegate = self
      cell.index = indexPath.row
      cell.dict = dict
      cell.initList(data: dict)
      print("!!!!")
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 45.5
    
  }
  
}
extension FoodUserListVC: FoodUserCellDelegate{
    func chat(userId: Int) {
        startChat(foodUserId: userId)
    }
    
    func delete(userId: Int,index: Int) {
        removeFoodUser(foodUserId: userId,index: index)
    }
    
    
}
