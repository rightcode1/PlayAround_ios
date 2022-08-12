//
//  NotificationLogVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/07/28.
//

import Foundation
import UIKit

class NotificationLogVC: BaseViewController{
  @IBOutlet weak var mainTableView: UITableView!
  
  var notifyList : [NotifyList] = []
  
  override func viewDidLoad() {
    initList()
    initdelegate()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
  }
  
  func initdelegate(){
    mainTableView.delegate = self
    mainTableView.dataSource = self
  }
  
  func initList() {
    self.showHUD()
    APIProvider.shared.authAPI.rx.request(.notificationLogList)
      .filterSuccessfulStatusCodes()
      .map(NotifyListResponse.self)
      .subscribe(onSuccess: { value in
        self.notifyList = value.list
        self.mainTableView.reloadData()
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
}
extension NotificationLogVC: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notifyList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let dict = notifyList[indexPath.row]
    let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
    guard let userthumbnail = cell.viewWithTag(1) as? UIImageView,
          let thumbnail = cell.viewWithTag(2) as? UIImageView,
          let titleLabel = cell.viewWithTag(3) as? UILabel,
          let createAt = cell.viewWithTag(4) as? UILabel else {
            return cell
          }
    if dict.userThumbnail != nil {
      userthumbnail.kf.setImage(with: URL(string: dict.userThumbnail ?? ""))
    } else {
      userthumbnail.image = UIImage(named: "noImage")
    }
    if dict.thumbnail != nil {
      thumbnail.kf.setImage(with: URL(string: dict.thumbnail ?? ""))
    } else {
      thumbnail.image = UIImage(named: "noImage")
    }
    titleLabel.text = dict.message
    createAt.text = dict.createdAt
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = notifyList[indexPath.row]
    if dict.diff == "used" {
      let vc = UIStoryboard.init(name: "Used", bundle: nil).instantiateViewController(withIdentifier: "UsedDetailVC") as! UsedDetailVC
      vc.usedId = dict.data
      self.navigationController?.pushViewController(vc, animated: true)
      
    }else  if dict.diff == "food"  {
      let vc = UIStoryboard.init(name: "Food", bundle: nil).instantiateViewController(withIdentifier: "FoodDetailVC") as! FoodDetailVC
      vc.foodId = dict.data
      self.navigationController?.pushViewController(vc, animated: true)
      
    }else  if dict.diff == "community"  {
      let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityDetailVC") as! CommunityDetailVC
      vc.communityId = dict.data
      self.navigationController?.pushViewController(vc, animated: true)
      
    }else {
      let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityInfoDetailVC") as! CommunityInfoDetailVC
      vc.detailId = dict.data
      self.navigationController?.pushViewController(vc, animated: true)
      
    }
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 88.5
  }
}

