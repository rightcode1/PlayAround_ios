//
//  villageDetailVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/06/22.
//

import Foundation
import UIKit

class villageDetailVC: BaseViewController{
  @IBOutlet weak var mainTableView: UITableView!
  var villageList : [village] = []
  var viewController: String = ""
  var selectIndex: Int?
  
  override func viewDidLoad() {
    setMainTableView()
    initVillageList()
  }
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
  }
  

  func setMainTableView(){
    DataHelper<String>.remove(forKey: .token)
    mainTableView.delegate = self
    mainTableView.dataSource = self
  }
  func initVillageList(){
    self.showHUD()
    APIProvider.shared.villageAPI.rx.request(.villageList(param: VillageListRequest(latitude: "\(currentLocation?.0 ?? 0.0)", longitude: "\(currentLocation?.1 ?? 0.0)", isMyVillage: "false")))
      .filterSuccessfulStatusCodes()
      .map(VillageListResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          self.villageList = value.list
          self.mainTableView.reloadData()
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  func myVillageRegister(){
    self.showHUD()
    APIProvider.shared.villageAPI.rx.request(.MyVillageRegist(param: MyVillage(villageId: villageList[selectIndex!].id)))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          self.showToast(message: "동네인증에 성공하였습니다.")
          if self.viewController == "join"{
              let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "VillageListVC") as! VillageListVC
              vc.viewController = "join"
              self.navigationController?.pushViewController(vc, animated: true)
          }else{
            self.backPress()
          }
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  @IBAction func tapRegister(_ sender: Any) {
    if selectIndex != nil {
      myVillageRegister()
    }else{
      okActionAlert(message: "동네를 선택해주세요.") {
      }
    }
  }
}
extension villageDetailVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return villageList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "villageDetailCell", for: indexPath)
      guard let check = cell.viewWithTag(1) as? UIImageView,
            let address = cell.viewWithTag(2) as? UILabel,
            let status = cell.viewWithTag(3) as? UILabel else {
              return cell
            }
    if indexPath.row != selectIndex{
      villageList[indexPath.row].isselect = false
    }else{
      villageList[indexPath.row].isselect = true
    }
    let dict = villageList[indexPath.row]
    address.text = dict.address
    check.image = dict.isselect ?? false ? UIImage(named: "checkOn") : UIImage(named: "checkOff")
    
    if !dict.isCert{
      status.text = "미인증"
      status.textColor = UIColor(red: 143, green: 143, blue: 143)
      
    }else{
      status.text = "인증완료"
      status.textColor = UIColor(red: 243, green: 112, blue: 34)
    }
    
      return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectIndex = indexPath.row
    mainTableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension

  }
  
}
