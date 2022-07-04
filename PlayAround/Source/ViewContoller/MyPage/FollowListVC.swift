//
//  FollowListVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/23.
//

import UIKit
import Moya

class FollowListVC: BaseViewController, ViewControllerFromStoryboard, FollowListCellDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  var isFollowing: Bool = false
  var followList: [Follow] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setTitle()
    setTableView()
  }
  
  static func viewController() -> FollowListVC {
    let viewController = FollowListVC.viewController(storyBoardName: "MyPage")
    return viewController
  }
  
  func setTitle() {
    self.navigationItem.title = isFollowing ? "팔로잉" : "팔로워"
  }
  
  func setTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.reloadData()
  }
  
  func updateRow(indexPath: IndexPath) {
    self.tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  func registFollow(userId: Int, result: @escaping (DefaultResponse) -> Void) {
    let param = RegistFollowRequest(userId: userId)
    APIProvider.shared.followAPI.rx.request(.register(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        result(value)
      }, onError: { error in
        let backendError = (error as? MoyaError)?.backendError
        print("backendError: \(backendError?.message ?? "")")
        result(DefaultResponse(statusCode: 400, message: backendError?.message ?? ""))
      })
      .disposed(by: disposeBag)
  }
  
  func removeFollow(userId: Int, result: @escaping (DefaultResponse) -> Void) {
    APIProvider.shared.followAPI.rx.request(.remove(userId: userId))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        result(value)
      }, onError: { error in
        let backendError = (error as? MoyaError)?.backendError
        print("backendError: \(backendError?.message ?? "")")
        result(DefaultResponse(statusCode: 400, message: backendError?.message ?? ""))
      })
      .disposed(by: disposeBag)
  }
  
  // FollowListCellDelegate
  func registFollow(indexPath: IndexPath) {
    let dict = followList[indexPath.row]
    if dict.isFollowing {
      removeFollow(userId: dict.id) { result in
        if result.statusCode <= 201 {
          self.followList[indexPath.row].isFollowing = false
          self.updateRow(indexPath: indexPath)
        }
      }
    } else {
      registFollow(userId: dict.id) { result in
        if result.statusCode <= 201 {
          self.followList[indexPath.row].isFollowing = true
          self.updateRow(indexPath: indexPath)
        }
      }
    }
  }
  
}

// MARK: - TableView
extension FollowListVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return followList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "FollowListCell") as! FollowListCell
    
    let dict = followList[indexPath.row]
    cell.indexPath = indexPath
    cell.delegate = self
    cell.update(dict)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = followList[indexPath.row]
    let vc = MyPageVC.viewController()
    vc.showUserId = dict.id
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.layoutMargins = .zero
    cell.separatorInset = .zero
    cell.selectionStyle = .none
    cell.preservesSuperviewLayoutMargins = false
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}
