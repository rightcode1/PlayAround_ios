//
//  HashtagListVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/14.
//

import UIKit

protocol HashtagListVCDelegate {
  func setHashtag(selectHashtag: [String])
}

class HashtagListVC: BaseViewController, ViewControllerFromStoryboard {
  @IBOutlet weak var searchTextField: UITextField!
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  @IBOutlet weak var registButton: UIButton!
  
  var delegate: HashtagListVCDelegate?
  
  private var hashtagList: [HashtagListData] = []
  var selectHashtag: [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setTableView()
    setCollectionView()
    
    bindInput()
  }
  
  static func viewController() -> HashtagListVC {
    let viewController = HashtagListVC.viewController(storyBoardName: "Food")
    return viewController
  }
  
  func setTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  func setCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
  }
  
  func initHashtagList() {
    let param = HashtagListRequest(search: searchTextField.text!, diff: .food)
    APIProvider.shared.hashtagAPI.rx.request(.list(param: param))
      .filterSuccessfulStatusCodes()
      .map(HashtagListResponse.self)
      .subscribe(onSuccess: { response in
        self.hashtagList = response.list
        
        self.tableView.reloadData()
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func bindInput() {
    searchTextField.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        self?.tableView.isHidden = text.isEmpty
        self?.collectionView.isHidden = !text.isEmpty
        
        self?.initHashtagList()
      })
      .disposed(by: disposeBag)
    
      registButton.rx.tap
        .bind(onNext: { [weak self] in
          guard let self = self else { return }
          if !self.searchTextField.text!.isEmpty {
            self.selectHashtag.append(self.searchTextField.text!)
            self.searchTextField.text = nil
            
            self.collectionView.reloadData()
            self.tableView.isHidden = true
            self.collectionView.isHidden = false
          }
        })
        .disposed(by: disposeBag)
  }
  
  @IBAction func tapBack(_ sender: UIBarButtonItem) {
    backPress()
    if selectHashtag.count > 0 {
      delegate?.setHashtag(selectHashtag: selectHashtag)
    }
  }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HashtagListVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hashtagList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
    let dict = hashtagList[indexPath.row]
    
    guard let nameLabel = cell.viewWithTag(1) as? UILabel else { return cell }
    nameLabel.text = "#\(dict.name)"
    
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = hashtagList[indexPath.row]
    
    selectHashtag.append(dict.name)
    searchTextField.text = nil
    
    collectionView.reloadData()
    self.collectionView.isHidden = false
    self.tableView.isHidden = true
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

extension HashtagListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return selectHashtag.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    
    let hashtag = selectHashtag[indexPath.row]
    (cell.viewWithTag(1) as! UILabel).text = "#\(hashtag)"
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectHashtag.remove(at: indexPath.row)
    self.collectionView.reloadData()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let hashtag = selectHashtag[indexPath.row]
    let text = "#\(hashtag)"
    
    let width = textWidth(text: text, font: .systemFont(ofSize: 13, weight: .regular)) + 21.5
    return CGSize(width: width, height: 19)
  }
}
