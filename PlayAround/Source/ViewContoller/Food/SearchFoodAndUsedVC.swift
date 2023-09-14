//
//  SearchFoodAndUsedVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/21.
//

import UIKit
import Moya

class SearchFoodAndUsedVC: BaseViewController, ViewControllerFromStoryboard, UITextFieldDelegate {
  
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var searchButton: UIImageView!
  @IBOutlet weak var searchKeywordHistoryRemoveAllButton: UIButton!
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var hashtagTableView: UITableView!
  
  @IBOutlet weak var diffCollectionView: UICollectionView!
  @IBOutlet weak var listCollectionView: UICollectionView!
  @IBOutlet weak var noneLIstImageView: UIImageView!
  
  let diffList: [WishDiff] = [.food, .used]
  var selectedDiff: WishDiff = .food
  
  var foodList: [FoodListData] = []
  var usedList: [UsedListData] = []
  var searchText : String?
  
  var hashtagList: [HashtagListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if searchText != nil{
      searchTextField.text = String(searchText!.dropFirst())
      search()
    }
    setTextField()
    setTableViews()
    setCollectionViews()
    updateSearchKeywordHistoryRemoveAllButton()
    
    bindInput()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
  }
  
  static func viewController() -> SearchFoodAndUsedVC {
    let viewController = SearchFoodAndUsedVC.viewController(storyBoardName: "Food")
    return viewController
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == searchTextField {
      self.search()
    }
    return true
  }
  
  func updateSearchKeywordHistoryRemoveAllButton() {
    searchKeywordHistoryRemoveAllButton.isHidden = (DataHelperTool.searchKeywordHistoryList ?? []).count <= 0
  }
  
  func setTextField() {
    searchTextField.delegate = self
  }
  
  func setTableViews() {
    hashtagTableView.delegate = self
    hashtagTableView.dataSource = self
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.reloadData()
  }
  
  func setCollectionViews() {
    diffCollectionView.delegate = self
    diffCollectionView.dataSource = self
    
    listCollectionView.delegate = self
    listCollectionView.dataSource = self
    
    diffCollectionView.reloadData()
  }
  
  func initList() {
    self.tableView.isHidden = true
    self.appendSearchKeywordHistory()
    
    if selectedDiff == .food {
      initFoodList()
    } else {
      initUsedList()
    }
  }
  
  func initFoodList() {
    let param = FoodListRequest(search: searchTextField.text)
    APIProvider.shared.foodAPI.rx.request(.foodList(param: param))
      .filterSuccessfulStatusCodes()
      .map(FoodListResponse.self)
      .subscribe(onSuccess: { value in
        self.foodList = value.list
        
        self.hashtagTableView.isHidden = true
        self.listCollectionView.isHidden = value.list.count <= 0
        self.noneLIstImageView.isHidden = value.list.count > 0
        
        self.listCollectionView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initUsedList() {
    let param = UsedListRequest(search: searchTextField.text)
    APIProvider.shared.usedAPI.rx.request(.list(param: param))
      .filterSuccessfulStatusCodes()
      .map(UsedListResponse.self)
      .subscribe(onSuccess: { value in
        self.usedList = value.list
        
        self.hashtagTableView.isHidden = true
        self.listCollectionView.isHidden = value.list.count <= 0
        self.noneLIstImageView.isHidden = value.list.count > 0
        
        self.listCollectionView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func appendSearchKeywordHistory() {
    var keywordList: [String] = DataHelperTool.searchKeywordHistoryList ?? []
    if keywordList.count >= 0 {
        if keywordList.isEmpty{
        keywordList.append(self.searchTextField.text!)
        }else if (keywordList.first != self.searchTextField.text!) {
        keywordList.insert(self.searchTextField.text!, at: 0)
      }
    }
    
    if keywordList.count > 50 {
      keywordList.removeLast()
    }
    
    DataHelper.set(keywordList, forKey: .searchKeywordHistoryList)
    updateSearchKeywordHistoryRemoveAllButton()
    self.tableView.reloadData()
  }
  
  func search() {
    if !self.searchTextField.text!.isEmpty {
      initList()
    }
  }
  
  func initHashtagList() {
    let param = HashtagListRequest(search: searchTextField.text!, diff: nil)
    APIProvider.shared.hashtagAPI.rx.request(.list(param: param))
      .filterSuccessfulStatusCodes()
      .map(HashtagListResponse.self)
      .subscribe(onSuccess: { response in
        self.hashtagList = response.list
        self.hashtagTableView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func bindInput() {
    searchTextField.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        guard let self = self else { return }
        
        self.tableView.isHidden = !text.isEmpty
        self.hashtagTableView.isHidden = text.isEmpty
        
        if !text.isEmpty {
          self.initHashtagList()
        }
      })
      .disposed(by: disposeBag)
    
    searchButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.search()
      })
      .disposed(by: disposeBag)
    
    searchKeywordHistoryRemoveAllButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        DataHelper<[String]>.remove(forKey: .searchKeywordHistoryList)
        self.updateSearchKeywordHistoryRemoveAllButton()
        self.tableView.reloadData()
      })
      .disposed(by: disposeBag)
  }
  
  @objc
  func searchKeyword(_ sender: UIButton) {
    if let index = Int(sender.accessibilityHint!) {
      let dict = (DataHelperTool.searchKeywordHistoryList ?? [])[index]
      searchTextField.text = dict
      search()
    }
  }
  
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchFoodAndUsedVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if hashtagTableView == tableView {
      return hashtagList.count
    } else {
      return (DataHelperTool.searchKeywordHistoryList ?? []).count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if hashtagTableView == tableView {
      let cell = self.hashtagTableView.dequeueReusableCell(withIdentifier: "cell")!
      let dict = hashtagList[indexPath.row]
      
      guard let nameLabel = cell.viewWithTag(1) as? UIButton else { return cell }
      
      nameLabel.setTitle("#\(dict.name)", for: .normal)
      
      cell.selectionStyle = .none
      return cell
    } else {
      let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
      let dict = (DataHelperTool.searchKeywordHistoryList ?? [])[indexPath.row]
      
      guard let nameButton = cell.viewWithTag(1) as? UIButton else { return cell }
      
      nameButton.setTitle(dict, for: .normal)
      nameButton.accessibilityHint = String(indexPath.row)
      nameButton.addTarget(self, action: #selector(searchKeyword(_:)), for: .touchUpInside)
      
      cell.selectionStyle = .none
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if hashtagTableView == tableView {
      let dict = hashtagList[indexPath.row]
      searchTextField.text = dict.name
      search()
    } else {
      let dict = (DataHelperTool.searchKeywordHistoryList ?? [])[indexPath.row]
      
      var keywordList: [String] = DataHelperTool.searchKeywordHistoryList ?? []
      keywordList.remove(dict)
      DataHelper.set(keywordList, forKey: .searchKeywordHistoryList)
      self.updateSearchKeywordHistoryRemoveAllButton()
      self.tableView.reloadData()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40.5
  }
}

extension SearchFoodAndUsedVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if diffCollectionView == collectionView {
      return diffList.count
    } else {
      return selectedDiff == .food ? foodList.count : usedList.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if diffCollectionView == collectionView {
      let cell = diffCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      let dict = diffList[indexPath.row]
      
      let selectedTextColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
      let defaultTextColor = UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0)
      
      (cell.viewWithTag(1) as! UILabel).text = dict.rawValue
      (cell.viewWithTag(1) as! UILabel).textColor = dict != selectedDiff ? defaultTextColor : selectedTextColor
      
      (cell.viewWithTag(2)!).isHidden = dict != selectedDiff
      
      return cell
    } else {
      let cell = listCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FoodListCell
      
      if selectedDiff == .food {
        let dict = foodList[indexPath.row]
        cell.update(dict)
      } else {
        let dict = usedList[indexPath.row]
        cell.update(dict)
      }
      
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if diffCollectionView == collectionView {
      let dict = diffList[indexPath.row]
      
      selectedDiff = dict
      diffCollectionView.reloadData()
      initList()
    } else {
      if selectedDiff == .food {
        let dict = foodList[indexPath.row]
        let vc = FoodDetailVC.viewController()
        vc.foodId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      } else {
        let dict = usedList[indexPath.row]
        let vc = UsedDetailVC.viewController()
        vc.usedId = dict.id
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if diffCollectionView == collectionView {
      let dict = diffList[indexPath.row]
      let width = textWidth(text: dict.rawValue, font: .systemFont(ofSize: 12, weight: .medium)) + 18
      
      return CGSize(width: width, height: 30)
    } else {
      let foodCellSize = CGSize(width: (APP_WIDTH() - 40) / 2, height: 195)
      let usedCellSize = CGSize(width: (APP_WIDTH() - 40) / 2, height: 175)
      
      return selectedDiff == .food ? foodCellSize : usedCellSize
    }
  }
}
