//
//  NoticeVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/20.
//

import UIKit

class NoticeVC: BaseViewController, ViewControllerFromStoryboard {
  
  @IBOutlet weak var tableView: UITableView!
  
  var noticeList: [NoticeListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setTableView()
    initNoticeList()
  }
  
  static func viewController() -> NoticeVC {
    let viewController = NoticeVC.viewController(storyBoardName: "Setting")
    return viewController
  }
  
  func setTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  func initNoticeList() {
    APIProvider.shared.noticeAPI.rx.request(.list)
      .filterSuccessfulStatusCodes()
      .map(NoticeListResponse.self)
      .subscribe(onSuccess: { response in
        self.noticeList = response.list
        
        self.tableView.reloadData()
      }, onError: { error in
        self.showToast(message: error.localizedDescription, yPosition: APP_HEIGHT() - 250)
      })
      .disposed(by: disposeBag)
  }
  
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NoticeVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return noticeList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
    let dict = noticeList[indexPath.row]
    
    guard let titleLabel = cell.viewWithTag(1) as? UILabel,
          let contentLabel = cell.viewWithTag(2) as? UILabel else { return cell }
    
    titleLabel.text = dict.title
    contentLabel.text = dict.content
    
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
}
