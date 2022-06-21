//
//  CommunityDetailRegisterVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/06/05.
//

import Foundation
import UIKit

class CommunityDetailRegisterVC:BaseViewController{
  var category: FoodCategory = .전체
  var foodList: [FoodListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
    initRegister()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
  }
  
  
  func initRegister() {
    self.showHUD()
    let param = FoodListRequest(category: category == .전체 ? nil : category)
    APIProvider.shared.foodAPI.rx.request(.foodList(param: param))
      .filterSuccessfulStatusCodes()
      .map(FoodListResponse.self)
      .subscribe(onSuccess: { value in
        self.foodList = value.list
        
        print("self.foodList.count : \(self.foodList.count)")
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  
  // FoodCategoryReusableViewDelegate
  func setCategory(category: FoodCategory) {
    self.category = category
  }
  
  @IBAction func tapVote(_ sender: Any) {
      let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityVote") as! CommunityVote
      self.navigationController?.pushViewController(vc, animated: true)
  }
}
