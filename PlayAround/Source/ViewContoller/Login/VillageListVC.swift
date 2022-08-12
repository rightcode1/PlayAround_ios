//
//  VillageListVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/06/22.
//

import Foundation
import UIKit

protocol SelectVillage{
  func select()
}

class VillageListVC: BaseViewController, UIViewControllerTransitioningDelegate{
  
  @IBOutlet weak var mainTableView: UITableView!
  
  var villageList : [village] = []
  var viewController : String = ""
  
  var delegate: SelectVillage?
  
  override func viewDidLoad() {
    setMainTableView()
    initVillageList()
  }
  func setMainTableView(){
    DataHelper<String>.remove(forKey: .token)
    mainTableView.delegate = self
    mainTableView.dataSource = self
  }
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
  }
  

  
  
  func initVillageList(){
    self.showHUD()
    APIProvider.shared.villageAPI.rx.request(.villageList(param: VillageListRequest(latitude: "\(currentLocation?.0 ?? 0.0)", longitude: "\(currentLocation?.1 ?? 0.0)", isMyVillage: "true")))
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
  func dateFormmater(_ date:String) -> Int{
    let dateFormatter = DateFormatter()
    var remainDay = 90
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // 2020-08-13 16:30
    
    let convertDate = dateFormatter.date(from: date) ?? Date() // Date 타입으로 변환
    
    let offsetComps = Calendar.current.dateComponents([.day], from: convertDate, to: Date())
    
    if case let (d?) = (offsetComps.day) {
      remainDay -= d
    }
    return remainDay
  }
}

extension VillageListVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return villageList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let dict = villageList[indexPath.row]
    let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "villageCell", for: indexPath)
    guard let address = cell.viewWithTag(1) as? UILabel,
          let status = cell.viewWithTag(2) as? UILabel else {
            return cell
          }
    address.text = dict.address
    if dict.isCert{
      status.text = "남은 인증 D-\(dateFormmater(dict.certDate ?? ""))"
    }else{
      status.text = "인증하기"
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = villageList[indexPath.row]
    
    let vc = UIStoryboard.init(name: "VillageDialog", bundle: nil).instantiateViewController(withIdentifier: "VillageDialogVC") as! VillageDialogVC
    vc.modalPresentationStyle = .custom
    vc.transitioningDelegate = self
    vc.delegate = self
    vc.indexPath = indexPath
    vc.titleString = dict.address
    self.present(vc, animated: true, completion: nil)
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
    
  }
  
}
extension VillageListVC: villageProtocol{
  func villageState(state: String, indexPath: IndexPath) {
    if state == "이동"{
      DataHelper.set(villageList[indexPath.row].address.split(separator: " ")[2], forKey: .villageName)
      delegate?.select()
      if viewController == "login"{
        goMain()
      }else{
        return backPress()
      }
    }
  }
  
}


