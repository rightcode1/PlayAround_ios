//
//  AdminCollectionViewCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/07/08.
//

import Foundation
import UIKit
import RxSwift

enum PermissionMenu: String, Codable {
  case notice = "공지"
  case board = "게시판"
  case chat = "채팅방"
  case delete = "글내리기"
}
protocol reloadPermit{
    func reload()
}
class AdminCommunityCell: UITableViewCell{
  @IBOutlet weak var permissionCollectionView: UICollectionView!
  
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var roomKingView: UIView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var tapOnOff: UIImageView!
  
  private let diffList: [PermissionMenu] = [.notice, .board, .chat, .delete]
  var checkBool: [Bool] = [false,false,false,false]
  var dict: CommunityJoiner?
  var MyCommunitiyUpdateVC: MyCommunitiyUpdateVC?
  var disposeBag = DisposeBag()
  var indexpath : IndexPath?
    var delegate: reloadPermit?
  var checkStatus: String?
  
  
  func initdelegate(_ check: Bool){
    permissionCollectionView.delegate = self
    permissionCollectionView.dataSource = self
    if check {
      permissionCollectionView.isHidden = true
    }else{
      permissionCollectionView.isHidden = false
    }
      permissionCollectionView.reloadData()
  }
  
  func initdata(_ data: CommunityJoiner,_ index: IndexPath, status: String?){
    dict = data
      if dict?.user.thumbnail != nil{
          userImageView.kf.setImage(with: URL(string: dict?.user.thumbnail ?? ""))
      }else{
              userImageView.image = UIImage(named: "defaultProfileImage")
      }
    if !(dict?.master ?? false){
      roomKingView.isHidden = true
    }else{
      roomKingView.isHidden = false
    }
    userNameLabel.text = dict?.user.name
    indexpath = index
    checkStatus = status
    if checkStatus == "참여" {
        tapOnOff.image = UIImage(named: "confirmNo")
    }else{
        tapOnOff.image = UIImage(named: "confirmYes")
    }
    intrx()
    
  }
  
  func initupdate(_ userid: Int, status: String?) {
    APIProvider.shared.communityAPI.rx.request(.CommunityJoinerUpdate(id : userid,param: CommunityJoinerUpdateRequest(authorityNotice: checkBool[0], authorityBoard: checkBool[1], authorityChat: checkBool[2], authorityDelete: checkBool[3],status: status)))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
          if status != nil {
              if status == "참여"{
                  self.tapOnOff.image = UIImage(named: "confirmNo")
              }else{
                  self.tapOnOff.image = UIImage(named: "confirmYes")
              }
          }else{
              self.delegate?.reload()
          }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  func intrx(){
    tapOnOff.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if self.dict?.master == true{
          
        }else{
          if self.checkStatus == "참여" {
            self.initupdate(self.dict!.id,status: "해제")
          }else{
            self.initupdate(self.dict!.id,status: "참여")
          }
        }
      })
      .disposed(by: disposeBag)
  }
  
}
extension AdminCommunityCell: UICollectionViewDelegate, UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return diffList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.permissionCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    let dict = diffList[indexPath.row].rawValue
    guard let diff = cell.viewWithTag(1) as? UILabel,
          let check = cell.viewWithTag(2) as? UIImageView else {
            return cell
          }
    diff.text = dict
    check.image = checkBool[indexPath.row] ? UIImage(named: "communityCheckOn") : UIImage(named: "communityCheckOff")
    return cell
  }
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      if dict?.user.id == DataHelperTool.userAppId{
          MyCommunitiyUpdateVC?.callOkActionMSGDialog(message:"방장의 권한은 해제할 수 없습니다.", okAction: {
          })
      }else{
          checkBool[indexPath.row] = !checkBool[indexPath.row]
          print("!!!!!!!")
          initupdate(dict!.id,status: nil)
      }
  }
  
}
