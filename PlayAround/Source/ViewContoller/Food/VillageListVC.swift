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
    @IBOutlet weak var noListImageView: UIImageView!
    
  var villageList : [village] = []
  var viewController : String = ""
  
  var delegate: SelectVillage?
  
//  override func viewDidLoad() {
//  }
  func setMainTableView(){
    mainTableView.delegate = self
    mainTableView.dataSource = self
  }
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
    setMainTableView()
    initVillageList()
  }
  

  
  
  func initVillageList(){
    self.showHUD()
    APIProvider.shared.villageAPI.rx.request(.villageList(param: VillageListRequest(isMyVillage: "true")))
      .filterSuccessfulStatusCodes()
      .map(VillageListResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          self.villageList = value.list
          self.mainTableView.reloadData()
            self.noListImageView.isHidden = !self.villageList.isEmpty
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
    func initVillageDelete(villageId:Int){
      self.showHUD()
      APIProvider.shared.villageAPI.rx.request(.MyVillageRemove(villageId: villageId))
        .filterSuccessfulStatusCodes()
        .map(DefaultResponse.self)
        .subscribe(onSuccess: { value in
          if(value.statusCode <= 200){
              self.showToast(message: "삭제되었습니다.")
              self.initVillageList()
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
          let status = cell.viewWithTag(2) as? UILabel,
          let backView = cell.viewWithTag(3) as? UIView else  {
            return cell
          }
    address.text = dict.address
    let data : Array<Substring> = dict.address.split(separator: " ")
    if data.last ?? "" == DataHelperTool.villageName ?? "" {
      backView.backgroundColor = UIColor(red: 255, green: 200, blue: 117)
    }
    if dict.isCert && dateFormmater(dict.certDate ?? "") >= 0{
      status.text = "남은 인증 D-\(dateFormmater(dict.certDate ?? ""))"
    }else{
      status.text = "인증하기"
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = villageList[indexPath.row]
    let data : Array<Substring> = dict.address.split(separator: " ")
    let vc = UIStoryboard.init(name: "VillageDialog", bundle: nil).instantiateViewController(withIdentifier: "VillageDialogVC") as! VillageDialogVC
    vc.modalPresentationStyle = .custom
    vc.transitioningDelegate = self
    vc.delegate = self
    vc.indexPath = indexPath
    vc.titleString = dict.address
    if data.last ?? "" == DataHelperTool.villageName ?? "" {
      vc.myVillage = true
    }else{
      vc.myVillage = false
    }
    self.present(vc, animated: true, completion: nil)
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
    
  }
  
}
extension VillageListVC: villageProtocol{
  func villageState(state: String, indexPath: IndexPath, myVillage: Bool) {
    if state == "이동"{
      let data : Array<Substring> = villageList[indexPath.row].address.split(separator: " ")
      DataHelper.set(data.last, forKey: .villageName)
      DataHelper.set(villageList[indexPath.row].id, forKey: .villageId)
      delegate?.select()
      if viewController == "login"{
        goMain()
      }else{
        return backPress()
      }
    }else{
      if myVillage{
        showToast(message: "선택된 동네는 삭제할 수 없습니다.\n다른 동네 선택 후 삭제해주세요.",line: 2)
      }else{
          initVillageDelete(villageId: villageList[indexPath.row].id)
      }
    }
  }
  
}


