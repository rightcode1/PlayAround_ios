//
//  MyCommunityCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/07/06.
//

import Foundation
import UIKit

class MyCommunityVC:BaseViewController, ViewControllerFromStoryboard{
  @IBOutlet weak var mainTableView: UITableView!
  @IBOutlet weak var noListImageView: UIImageView!
  
  var communityList: [CommuintyList] = []
  
  override func viewWillAppear(_ animated: Bool) {
    
      mainTableView.delegate = self
      mainTableView.dataSource = self
      initCommunityList()
  }
  
  func initCommunityList() {
    self.showHUD()
    let param = categoryListRequest(myList: "true")
    APIProvider.shared.communityAPI.rx.request(.CommuntyList(param: param))
      .filterSuccessfulStatusCodes()
      .map(CommunityResponse.self)
      .subscribe(onSuccess: { value in
        self.communityList = value.list
        self.mainTableView.reloadData()
        if self.communityList.isEmpty{
          self.noListImageView.isHidden = false
        }else{
          self.noListImageView.isHidden = true
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
}
extension MyCommunityVC: UITableViewDelegate, UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return communityList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommunityCell
    cell.initcell(communityList[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 125
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let vc = MyCommunitiyUpdateVC.viewController()
      vc.communityId = communityList[indexPath.row].id
      vc.data = communityList[indexPath.row]
      self.navigationController?.pushViewController(vc, animated: true)
  }
  
}
