//
//  CommunityDetailNoticeVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/31.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class CommunityInfoDetailVC:BaseViewController,CommunityDetailMenuDelegate{
  
  @IBOutlet weak var mainTableView: UITableView!
  @IBOutlet weak var imageCollectionView: UICollectionView!
  
  @IBOutlet weak var infoImageView: UIImageView!
  @IBOutlet weak var userImageView: UIImageView!
  
  
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var voteHiddenView: UIView!
  @IBOutlet weak var commentView: UIView!
  @IBOutlet weak var replyView: UIView!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var commentCountLabel: UILabel!
  @IBOutlet weak var replyLabel: UILabel!
  
  @IBOutlet weak var commentButton: UIImageView!
  @IBOutlet weak var reigstCommentButton: UIButton!
  @IBOutlet weak var naviMenuButton: UIBarButtonItem!
  
  @IBOutlet weak var resetLabel: UILabel!
  @IBOutlet weak var inputTextView: UITextView! {
    didSet {
      inputTextView.delegate = self
    }
  }
  
  
  var isMine : Bool = false
  

  var replyCommentId: Int?
  var naviTitle: String?
  var detailId: Int?
  var imageList: [Image?] = []
  var comment: [Comment] = []
  
  override func viewDidLoad() {
    navigationController?.title  = naviTitle
    self.showHUD()
    initDelegate()
    navigationItem.title = naviTitle
    if naviTitle == "공지사항"{
      initNoticeDetail()
    }else{
      initBoardDetail()
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    IQKeyboardManager.shared.enableAutoToolbar = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    IQKeyboardManager.shared.enableAutoToolbar = true
  }
  
  func initDelegate(){
    initrx()
    mainTableView.delegate = self
    mainTableView.dataSource = self
    voteHiddenView.isHidden = true
    infoImageView.isHidden = true
    imageCollectionView.delegate = self
    imageCollectionView.dataSource = self
    
    imageCollectionView.register(UINib(nibName: "CollectionViewImageCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewImageCell")

  }
  
  func initNoticeDetail() {
    APIProvider.shared.communityAPI.rx.request(.CommuntyNoticeDetail(id: detailId!))
      .filterSuccessfulStatusCodes()
      .map(CommunityInfoDetailResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          print(value.data)
          self.initNoticeComment(value.data.id)
          self.initDetail(value.data)
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initNoticeComment(_ id: Int) {
    APIProvider.shared.communityAPI.rx.request(.CommuntyNoticeComment(id: id))
      .filterSuccessfulStatusCodes()
      .map(CommunityCommentResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          print(value.list)
          self.commentCountLabel.text = "\(value.list.count)"
          self.comment = value.list
          self.mainTableView.reloadData()
          self.mainTableView.scrollToBottom()
        }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initBoardDetail() {
    APIProvider.shared.communityAPI.rx.request(.CommuntyBoardDetail(id: detailId!))
      .filterSuccessfulStatusCodes()
      .map(CommunityInfoDetailResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          print(value.data)
          self.initBoardComment(value.data.id)
          self.initDetail(value.data)
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  func initBoardComment(_ id: Int) {
    APIProvider.shared.communityAPI.rx.request(.CommuntyBoardComment(id: id))
      .filterSuccessfulStatusCodes()
      .map(CommunityCommentResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          self.commentCountLabel.text = "\(value.list.count)"
          self.comment = value.list
          self.mainTableView.reloadData()
        }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func registComment() {
    let param = RegistCommunityCommentRequest(communityNoticeId: detailId!, content: inputTextView.text, communityNoticeCommentId: replyCommentId)
    APIProvider.shared.communityAPI.rx.request(.NoticeCommentRegister(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.inputTextView.text = nil
        self.initNoticeComment(self.detailId ?? 0)
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  func registBoardComment() {
    let param = RegistCommunityBoardCommentRequest(communityBoardId: detailId!, content: inputTextView.text, communityBoardCommentId: replyCommentId)
    APIProvider.shared.communityAPI.rx.request(.BoardCommentRegister(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultResponse.self)
      .subscribe(onSuccess: { value in
        self.inputTextView.text = nil
        self.initBoardComment(self.detailId ?? 0)
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func initDetail(_ data: CommunityInfo){
    if(data.images.count != 0){
      imageList = data.images
      imageCollectionView.isHidden = false
    }else{
      imageCollectionView.isHidden = true
    }
    mainTableView.layoutTableHeaderView()
    titleLabel.text = data.title
    userNameLabel.text = data.user.name
    dateLabel.text = data.createdAt
    contentLabel.text = data.content
    if(data.user.thumbnail != nil){
      userImageView?.kf.setImage(with: URL(string: data.user.thumbnail!))
    }
    imageCollectionView.reloadData()
    self.dismissHUD()
  }
  
  func initrx(){
    commentButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.commentView.isHidden = false
      })
      .disposed(by: disposeBag)
    
    inputTextView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.inputTextView.becomeFirstResponder() // ?
      })
      .disposed(by: disposeBag)
    
    reigstCommentButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if !self.inputTextView.text.isEmpty {
          
          if self.naviTitle == "공지사항"{
            self.registComment()
          }else{
            self.registBoardComment()
          }
        }
      })
      .disposed(by: disposeBag)
    
    naviMenuButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = CommunityDetailMenuPopupVC.viewController()
        vc.isMine.onNext(self.isMine)
        vc.delegate = self
        self.present(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
  }
  
  func shareCommunity() {
    
  }
  
  func updateCommunity() {
    
  }
  
  func removeCommunity() {
    
  }
  
  func reportCommunity() {
    
  }
  func setTextViewHeight() {
    let size = CGSize(width: inputTextView.frame.width, height: .infinity)
    let estimatedSize = inputTextView.sizeThatFits(size)
    inputTextView.constraints.forEach { (constraint) in
      
      if constraint.firstAttribute == .height {
        constraint.constant = estimatedSize.height
      }
    }
  }
}

extension CommunityInfoDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.imageCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewImageCell", for: indexPath)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: APP_WIDTH(), height: 225)
  }
  
}
extension CommunityInfoDetailVC: UITableViewDataSource, UITableViewDelegate {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comment.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
    let dict = comment[indexPath.row]
    cell.initComment(dict)
    cell.delegate = self
    return cell
  }

//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let dict = comment[indexPath.row]
    
    let mainWidth = UIScreen.main.bounds.width
    
    let textHeight = dict.content.height(withConstrainedWidth: mainWidth - (dict.depth == 1 ? 72 : 112), font: .systemFont(ofSize: 13))
    
    return (textHeight + 57)
  }

}

extension CommunityInfoDetailVC: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    resetLabel.isHidden = true
    let spacing = CharacterSet.whitespacesAndNewlines
    if !textView.text.trimmingCharacters(in: spacing).isEmpty || !textView.text.isEmpty {
      textView.textColor = .black
    } else if textView.text.isEmpty {
      textView.textColor = .lightGray
    }
    setTextViewHeight()
  }
}
extension CommunityInfoDetailVC:tapCommentProtocol{
  func tapComment(commentId: Int?, userName: String) {
    replyCommentId = commentId
    commentView.isHidden = false
    replyLabel.text = "\(userName)님에게 답글 다는 중..."
    UIView.animate(withDuration: 0.5) {
      self.replyView.alpha = 1.0
      self.replyView.layoutIfNeeded()
    }
  }
}
