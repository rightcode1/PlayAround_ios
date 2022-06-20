//
//  FAQVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/20.
//

import UIKit

class FAQVC: BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var diffCollectionView: UICollectionView!
  @IBOutlet var tableView: UITableView!
  
  var faqList: [FAQListData] = []
  let diffList: [FAQDiff] = [.동네생활, .이용방법, .약관, .거래, .기타, .약관2]
  var selectedDiff: FAQDiff = .동네생활
  private var selectedRow: Int = -1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setCollectionView()
    setTableView()
    initFAQList()
  }
  
  func setCollectionView() {
    diffCollectionView.delegate = self
    diffCollectionView.dataSource = self
  }
  
  func setTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  static func viewController() -> FAQVC {
    let viewController = FAQVC.viewController(storyBoardName: "Setting")
    return viewController
  }
  
  func initFAQList() {
    APIProvider.shared.faqAPI.rx.request(.list(diff: selectedDiff))
      .filterSuccessfulStatusCodes()
      .map(FAQListResponse.self)
      .subscribe(onSuccess: { response in
        self.faqList = response.list
        self.tableView.reloadData()
      }, onError: { error in
        self.showToast(message: error.localizedDescription, yPosition: APP_HEIGHT() - 250)
      })
      .disposed(by: disposeBag)
  }
  
}

extension FAQVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return faqList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "FAQListCell") as! FAQListCell
    let data = faqList[indexPath.row]
    
    cell.index = indexPath.row
    cell.update(data)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if faqList.count > 0 {
      var updateIndexPath: [IndexPath] = []
      
      if self.selectedRow == indexPath.row {
        let preIndexPath = IndexPath(row: self.selectedRow, section: indexPath.section)
        self.faqList[self.selectedRow].isOpened = false
        updateIndexPath.append(preIndexPath)
        self.selectedRow = -1
        
      } else {
        if self.selectedRow != -1 {
          let preIndexPath = IndexPath(row: self.selectedRow, section: indexPath.section)
          self.faqList[self.selectedRow].isOpened = false
          updateIndexPath.append(preIndexPath)
        }
        
        self.selectedRow = indexPath.row
        self.faqList[indexPath.row].isOpened = true
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

extension FAQVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return diffList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = diffCollectionView.dequeueReusableCell(withReuseIdentifier: "diffCell", for: indexPath)
    
    let dict = diffList[indexPath.row]
    
    let selectedTextColor = UIColor(red: 243/255, green: 112/255, blue: 34/255, alpha: 1.0)
    let defaultTextColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1.0)
    
    (cell.viewWithTag(1) as! UILabel).text = dict.rawValue
    (cell.viewWithTag(1) as! UILabel).textColor = dict != selectedDiff ? defaultTextColor : selectedTextColor
//    (cell.viewWithTag(2)!).isHidden = dict != selectedDiff
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let dict = diffList[indexPath.row]
    
    selectedDiff = dict
    diffCollectionView.reloadData()
    initFAQList()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (APP_WIDTH() - 1) / 3
    return CGSize(width: width, height: 50)
  }
}
