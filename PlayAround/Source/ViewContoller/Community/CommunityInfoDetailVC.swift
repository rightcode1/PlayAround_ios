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
    @IBOutlet weak var subTableView: UITableView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var subTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var replyView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dislikeCountLabel: UILabel!
    @IBOutlet weak var downCountLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    
    @IBOutlet weak var commentButton: UIImageView!
    @IBOutlet weak var reigstCommentButton: UIButton!
    @IBOutlet weak var naviMenuButton: UIBarButtonItem!
    
    @IBOutlet weak var likeButton: UIImageView!
    @IBOutlet weak var disLikeButton: UIImageView!
    @IBOutlet weak var downButton: UIImageView!
    @IBOutlet weak var reportView: UIView!
    
    @IBOutlet weak var resetLabel: UILabel!
    @IBOutlet weak var inputTextView: UITextView! {
        didSet {
            inputTextView.delegate = self
        }
    }
    
    @IBOutlet weak var voteTitleLabel: UILabel!
    @IBOutlet weak var voteDateLabel: UILabel!
    @IBOutlet weak var voteOverLap: UILabel!
    
    var isMine : Bool = false
    
    
    var replyCommentId: Int?
    var naviTitle: String?
    var detailId: Int?
    var imageList: [Image?] = []
    var comment: [Comment] = []
    var voteList: [choice] = []
    var status: Bool?
    var downstatus: Bool = false
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
        subTableView.delegate = self
        subTableView.dataSource = self
        infoImageView.isHidden = true
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
//
//        imageCollectionView.register(UINib(nibName: "CollectionViewImageCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewImageCell")
        
    }
    
    func likeButtonState(state: Bool?){
        if state == nil{
            self.likeButton.image = UIImage(named: "likeoff")
            self.disLikeButton.image = UIImage(named: "dislikeoff")
            
        }else if state == true{
            self.disLikeButton.image = UIImage(named: "dislikeoff")
            self.likeButton.image = UIImage(named: "like")
        }else if state == false{
            self.likeButton.image = UIImage(named: "likeoff")
            self.disLikeButton.image = UIImage(named: "dislike")
        }
        
    }
    
    func initNoticeDetail() {
        APIProvider.shared.communityAPI.rx.request(.CommuntyNoticeDetail(id: detailId!))
            .filterSuccessfulStatusCodes()
            .map(CommunityInfoDetailResponse.self)
            .subscribe(onSuccess: { value in
                if(value.statusCode <= 200){
                    self.initNoticeComment(value.data.id,false)
                    self.initNoticeVoteDetail(value.data.id)
                    self.initDetail(value.data)
                }
                self.dismissHUD()
            }, onError: { error in
                self.dismissHUD()
            })
            .disposed(by: disposeBag)
    }
    func initNoticeVoteDetail(_ detailId: Int) {
        APIProvider.shared.communityAPI.rx.request(.CommuntyNoticeVoteDetail(id: detailId))
            .filterSuccessfulStatusCodes()
            .map(CommunityVoteResponse.self)
            .subscribe(onSuccess: { value in
                if(value.statusCode <= 200){
                    if !value.list.isEmpty{
                        self.mainTableView.layoutTableHeaderView()
                        self.subTableView.layoutTableHeaderView()
                        self.subTableView.isHidden = false
                        self.subTableViewHeight.constant = CGFloat(90 + 50 * value.list[0].choice.count)
                        self.voteDateLabel.text = value.list[0].endDate
                        self.voteTitleLabel.text = value.list[0].title
                        self.voteList = value.list[0].choice
                        self.subTableView.reloadData()
                        if value.list[0].overlap{
                            self.voteOverLap.text = "중복선택 가능"
                        }else{
                            self.voteOverLap.text = "중복선택 불가"
                        }
                    }else{
                        self.subTableView.isHidden = true
                    }
                }
                self.dismissHUD()
            }, onError: { error in
                self.dismissHUD()
            })
            .disposed(by: disposeBag)
    }
    
  func initNoticeComment(_ id: Int,_ regist:Bool) {
        APIProvider.shared.communityAPI.rx.request(.CommuntyNoticeComment(id: id))
            .filterSuccessfulStatusCodes()
            .map(CommunityCommentResponse.self)
            .subscribe(onSuccess: { value in
                if(value.statusCode <= 200){
                    print(value.list)
                    self.commentCountLabel.text = "\(value.list.count)"
                    self.comment = value.list
                    self.mainTableView.reloadData()
                  if regist{
                    self.mainTableView.scrollToBottom()
                    self.view.endEditing(true)
                    self.replyView.isHidden = true
                    self.commentView.isHidden = true
                  }
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
                    self.initBoardComment(value.data.id,false)
                    self.initDetail(value.data)
                }
                self.dismissHUD()
            }, onError: { error in
                self.dismissHUD()
            })
            .disposed(by: disposeBag)
    }
    
    func initBoardComment(_ id: Int,_ regist:Bool) {
        APIProvider.shared.communityAPI.rx.request(.CommuntyBoardComment(id: id))
            .filterSuccessfulStatusCodes()
            .map(CommunityCommentResponse.self)
            .subscribe(onSuccess: { value in
                if(value.statusCode <= 200){
                    self.commentCountLabel.text = "\(value.list.count)"
                    self.comment = value.list
                    self.mainTableView.reloadData()
                  if regist{
                    self.mainTableView.scrollToBottom()
                    self.view.endEditing(true)
                    self.replyView.isHidden = true
                    self.commentView.isHidden = true
                  }
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
                self.initNoticeComment(self.detailId ?? 0,true)
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
                self.initBoardComment(self.detailId ?? 0,true)
            }, onError: { error in
            })
            .disposed(by: disposeBag)
    }
    
    func registLike(isLike: Bool) {
        let param = ComunityInfoLikeRequest(isLike: isLike, communityNoticeId: detailId)
        APIProvider.shared.communityAPI.rx.request(.CommuntyInfoLike(param: param))
            .filterSuccessfulStatusCodes()
            .map(DefaultResponse.self)
            .subscribe(onSuccess: { value in
                self.status = isLike
                if self.status == true{
                    self.likeCountLabel.text = "\((Int(self.likeCountLabel.text ?? "0") ?? 0) + 1)"
                }else if self.status == false{
                    self.dislikeCountLabel.text = "\((Int(self.dislikeCountLabel.text ?? "0") ?? 0) + 1)"
                }else{
                    
                }
                self.likeButtonState(state: isLike)
            }, onError: { error in
            })
            .disposed(by: disposeBag)
    }
    
    func removeLike() {
        APIProvider.shared.communityAPI.rx.request(.CommuntyInfoDisLike(id: detailId ?? 0))
            .filterSuccessfulStatusCodes()
            .map(DefaultResponse.self)
            .subscribe(onSuccess: { value in
                if self.status == true{
                    self.likeCountLabel.text = "\((Int(self.likeCountLabel.text ?? "0") ?? 0) - 1)"
                }else if self.status == false{
                    self.dislikeCountLabel.text = "\((Int(self.dislikeCountLabel.text ?? "0") ?? 0) - 1)"
                }else{
                    
                }
                self.status = nil
                self.likeButtonState(state: nil)
            }, onError: { error in
            })
            .disposed(by: disposeBag)
    }
    func registDown() {
        if self.naviTitle == "공지사항"{
            let param = ComunityNoticeDownRequest(communityNoticeId: detailId)
            APIProvider.shared.communityAPI.rx.request(.CommunityNoticeDown(param: param))
                .filterSuccessfulStatusCodes()
                .map(DefaultResponse.self)
                .subscribe(onSuccess: { value in
                    self.downstatus = true
                    self.downButton.image = UIImage(named: "downPostOn")
                    self.downCountLabel.text = "\((Int(self.downCountLabel.text ?? "0") ?? 0) + 1)"
                }, onError: { error in
                })
                .disposed(by: disposeBag)
        }else{
            let param = ComunityBoardDownRequest(communityBoardId: detailId)
            APIProvider.shared.communityAPI.rx.request(.CommunityBoardDown(param: param))
                .filterSuccessfulStatusCodes()
                .map(DefaultResponse.self)
                .subscribe(onSuccess: { value in
                    self.downstatus = true
                    self.downButton.image = UIImage(named: "downPostOn")
                    self.downCountLabel.text = "\((Int(self.downCountLabel.text ?? "0") ?? 0) + 1)"
                }, onError: { error in
                })
                .disposed(by: disposeBag)
            
        }
    }
    
    func removeDown() {
        APIProvider.shared.communityAPI.rx.request(.CommunityNoticeDownOff(id: detailId ?? 0))
            .filterSuccessfulStatusCodes()
            .map(DefaultResponse.self)
            .subscribe(onSuccess: { value in
                self.downstatus = false
                self.downButton.image = UIImage(named: "downPost")
                self.downCountLabel.text = "\((Int(self.downCountLabel.text ?? "0") ?? 0) - 1)"
            }, onError: { error in
            })
            .disposed(by: disposeBag)
    }
    
    
    func removeComment(id: Int,index: Int) {
        APIProvider.shared.communityAPI.rx.request(.communityNoticeCommentRemove(id: id))
            .filterSuccessfulStatusCodes()
            .map(DefaultResponse.self)
            .subscribe(onSuccess: { value in
                self.comment.remove(at: index)
                self.mainTableView.reloadData()
                self.showToast(message: "삭제되었습니다.")
            }, onError: { error in
            })
            .disposed(by: disposeBag)
    }
    func removeAndRegistLike(isLike: Bool) {
        APIProvider.shared.communityAPI.rx.request(.CommuntyInfoDisLike(id: detailId ?? 0))
            .filterSuccessfulStatusCodes()
            .map(DefaultResponse.self)
            .subscribe(onSuccess: { value in
                let param = ComunityInfoLikeRequest(isLike: isLike, communityNoticeId: self.detailId)
                APIProvider.shared.communityAPI.rx.request(.CommuntyInfoLike(param: param))
                    .filterSuccessfulStatusCodes()
                    .map(DefaultResponse.self)
                    .subscribe(onSuccess: { value in
                        self.status = isLike
                        if self.status == true{
                            self.likeCountLabel.text = "\((Int(self.likeCountLabel.text ?? "0") ?? 0) + 1)"
                            self.dislikeCountLabel.text = "\((Int(self.dislikeCountLabel.text ?? "0") ?? 0) - 1)"
                        }else{
                            self.dislikeCountLabel.text = "\((Int(self.dislikeCountLabel.text ?? "0") ?? 0) + 1)"
                            self.likeCountLabel.text = "\((Int(self.likeCountLabel.text ?? "0") ?? 0) - 1)"
                        }
                        self.likeButtonState(state: isLike)
                    }, onError: { error in
                    })
                    .disposed(by: self.disposeBag)
            }, onError: { error in
            })
            .disposed(by: disposeBag)
    }
    
    func initDetail(_ data: CommunityInfo){
        if(data.images.count != 0){
            imageList = data.images
            imageCollectionView.isHidden = false
            imageCollectionView.isScrollEnabled = false
            var totalHeight :CGFloat = 0
            for count in 0 ..< imageList.count{
                let dict = imageList[count]
                let data = try! Data(contentsOf: URL(string: dict?.name ?? "")!)
                let image = UIImage(data: data)
                totalHeight += image?.resizeToFloat(newWidth: APP_WIDTH()) ?? 0
            }
            imageHeight.constant = totalHeight
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
        if data.authorityDelete {
            reportView.isHidden = false
            downstatus = data.isOut
            downButton.image = downstatus ? UIImage(named: "downPostOn") : UIImage(named: "downPost")
        }else{
            reportView.isHidden = true
        }
        status = data.isLike
        likeCountLabel.text = "\(data.likeCount)"
        dislikeCountLabel.text = "\(data.dislikeCount)"
        downCountLabel.text = "\(data.outCount)"
        likeButtonState(state: status)
        imageCollectionView.reloadData()
        self.dismissHUD()
    }
    
    func initrx(){
        commentButton.rx.tapGesture().when(.recognized)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.commentView.isHidden = false
              self.mainTableView.scrollToBottom()
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
        
        likeButton.rx.tapGesture().when(.recognized)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                if self.status == nil{
                    self.registLike(isLike: true)
                }else if self.status == false{
                    self.removeAndRegistLike(isLike: true)
                }else{
                    self.removeLike()
                }
                
            }).disposed(by: disposeBag)
        
        disLikeButton.rx.tapGesture().when(.recognized)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.status == nil{
                    self.registLike(isLike: false)
                }else if self.status == true{
                    self.removeAndRegistLike(isLike: false)
                }else{
                    self.removeLike()
                }
                
            }).disposed(by: disposeBag)
        downButton.rx.tapGesture().when(.recognized)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                if !self.downstatus {
                    self.registDown()
                }else{
                    self.showToast(message: "글내리기를 취소할 수 없습니다")
//                    self.removeDown()
                }
                
            }).disposed(by: disposeBag)
        
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
        let cell = self.imageCollectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath)
        guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
                return cell
              }
        let dict = imageList[indexPath.row]
        
        if let url = URL(string: dict?.name ?? ""), let data = try? Data(contentsOf: url) {
          let uiImage = UIImage(data: data)!
          let image = uiImage.resizeToWidth(newWidth: APP_WIDTH())
            thumbnail.image = image
        } else {
            thumbnail.image = UIImage(named: "defaultBoardImage")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dict = imageList[indexPath.row]
        let data = try! Data(contentsOf: URL(string: dict?.name ?? "")!)
        let image = UIImage(data: data)
        return CGSize(width: APP_WIDTH(), height: image?.resizeToFloat(newWidth: APP_WIDTH()) ?? 0)
    }
    
}
extension CommunityInfoDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.mainTableView{
            return comment.count
        }else{
            return voteList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.mainTableView{
            let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
            let dict = comment[indexPath.row]
            cell.ismine = DataHelperTool.userId == dict.user.loginId
            cell.initComment(dict)
            cell.index = indexPath.row
            cell.delegate = self
            return cell
        }else{
            let cell = self.subTableView.dequeueReusableCell(withIdentifier: "voteCell", for: indexPath)
            let dict = voteList[indexPath.row]
            guard let content = cell.viewWithTag(1) as? UILabel,
                  let count = cell.viewWithTag(2) as? UILabel else {
                    return cell
                  }
            content.text = dict.content
            count.text = "\(dict.count)"
            return cell
        }
    }
    
    //  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //  }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.mainTableView{
            let dict = comment[indexPath.row]
            
            let mainWidth = UIScreen.main.bounds.width
            
            let textHeight = dict.content.height(withConstrainedWidth: mainWidth - (dict.depth == 1 ? 72 : 112), font: .systemFont(ofSize: 13))
            
            return (textHeight + 57)
        }else{
          return UITableView.automaticDimension
        }
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
    func tapDelete(commentId: Int,index:Int) {
        removeComment(id: commentId, index: index)
    }
    
    func tapComment(commentId: Int?, userName: String) {
        replyCommentId = commentId
        commentView.isHidden = false
        replyView.isHidden = false
        replyLabel.text = "\(userName)님에게 답글 다는 중..."
        UIView.animate(withDuration: 0.5) {
            self.replyView.alpha = 1.0
            self.replyView.layoutIfNeeded()
        }
      mainTableView.scrollToBottom()
    }
}
