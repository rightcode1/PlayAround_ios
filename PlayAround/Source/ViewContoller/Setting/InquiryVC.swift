//
//  InquiryVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/20.
//

import UIKit

class InquiryVC: BaseViewController {
  @IBOutlet var tableView: UITableView!
  
  var inquiryList: [InquiryListData] = []
  private var selectedRow: Int = -1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setTableView()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    initInquiryList()
  }
  
  func setTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  func initInquiryList() {
    APIProvider.shared.inquiryAPI.rx.request(.list)
      .filterSuccessfulStatusCodes()
      .map(InquiryListResponse.self)
      .subscribe(onSuccess: { response in
        self.inquiryList = response.list
        self.tableView.reloadData()
      }, onError: { error in
        self.showToast(message: error.localizedDescription, yPosition: APP_HEIGHT() - 250)
      })
      .disposed(by: disposeBag)
  }
  
}
extension InquiryVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return inquiryList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "InquiryListCell") as! InquiryListCell
    let data = inquiryList[indexPath.row]
    
    cell.update(data)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if inquiryList.count > 0 {
      var updateIndexPath: [IndexPath] = []
      
      if self.selectedRow == indexPath.row {
        let preIndexPath = IndexPath(row: self.selectedRow, section: indexPath.section)
        self.inquiryList[self.selectedRow].isOpened = false
        updateIndexPath.append(preIndexPath)
        self.selectedRow = -1
        
      } else {
        if self.selectedRow != -1 {
          let preIndexPath = IndexPath(row: self.selectedRow, section: indexPath.section)
          self.inquiryList[self.selectedRow].isOpened = false
          updateIndexPath.append(preIndexPath)
        }
        
        self.selectedRow = indexPath.row
        self.inquiryList[indexPath.row].isOpened = true
        updateIndexPath.append(indexPath)
      }
      
      self.tableView.reloadRows(at: updateIndexPath, with: .none)
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.layoutMargins = .zero
    cell.separatorInset = .zero
    cell.selectionStyle = .none
    cell.preservesSuperviewLayoutMargins = false
  }
  
}
