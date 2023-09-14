//
//  CommunityDetailVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/30.
//

import Foundation
import UIKit
import XLPagerTabStrip
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import SocketIO

enum Category: String, Codable {
    case 공지사항
    case 자유게시판
    case 채팅방
}
class CommunityDetailVC: BaseViewController, ViewControllerFromStoryboard, CommunityDetailMenuDelegate, DialogPopupViewDelegate{
  func dialogOkEvent() {
        self.joinBoard(self.communityId)
    }
    
    func shareCommunity() {
        var image: String = ""
        if !(detaildata?.images.isEmpty ?? false){
            image = detaildata?.images[0].name ?? ""
        }
        let feedTemplateJsonStringData =
          """
          {
            "object_type": "feed",
            "content": {
              "title": "\(detaildata?.name ?? "")",
              "image_url": "\(image)",
              "link": {
                "mobile_web_url": "https://developers.kakao.com",
                "web_url": "https://developers.kakao.com"
              }
            },
            "buttons": [
              {
                "title": "앱으로 보기",
                "link": {
                  "android_execution_params": "boardId=\(detaildata?.id ?? 0)",
                  "ios_execution_params": "boardId=\(detaildata?.id ?? 0)"
                }
              }
            ]
          }
          """.data(using: .utf8)!
        guard let templatable = try? SdkJSONDecoder.custom.decode(FeedTemplate.self, from: feedTemplateJsonStringData) else { return }
        if ShareApi.isKakaoTalkSharingAvailable() {
            ShareApi.shared.shareDefault(templatable: templatable) { sharingResult, error in
                if let sharingResult = sharingResult {
                    print(sharingResult.url)
                    UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    func updateCommunity() {
        
    }
    
    func removeCommunity() {
        
    }
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var likeButton: UIImageView!
    @IBOutlet weak var dislikeButton: UIImageView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanToMeLabel: UILabel!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var disLikeLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var thumbnailCountLabel: UILabel!
    
    
    
    @IBOutlet weak var likeImageVIew: UIImageView!
    @IBOutlet weak var dislikeImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    
    let socketManager = SocketIOManager.sharedInstance
    
    var communityId: Int = 0
    var isMine : Bool = false
    var imageList: [Image] = []
    var isLike : Bool?
    var isStatus: Bool = false
    var detaildata: CommunityDetail?
    var communityBoard: [CommunityBoard] = []
    var communityNotice: [CommunityNotice] = []
    var communityChat: [ChatRoomData] = []
    
    var selectedCategory = "공지사항"
    var category: [Category] = [.공지사항, .자유게시판, .채팅방]
    var authorityNotice:Bool = false
    var authorityBoard:Bool = false
    var authorityChat:Bool = false
    var authorityDelete:Bool = false
    var isSecret:Bool = false
    override func viewDidLoad() {
      initDetailBoard(communityId)
      initDetailNotice(communityId)
      initChatRoomList()
        initDetail()
        initrx()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        initDelegate()
        if selectedCategory == "공지사항"{
            initDetailNotice(communityId)
        }else if selectedCategory == "자유게시판"{
            initDetailBoard(communityId)
        }else{
          initChatRoomList()
        }
    }
  
    static func viewController() -> CommunityDetailVC {
        let viewController = CommunityDetailVC.viewController(storyBoardName: "Community")
        return viewController
    }
    func initDelegate(){
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.layoutTableHeaderView()
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
    }
    
    func initDetail() {
        self.showHUD()
        let param = communityDetailRequest(latitude:  "\(currentLocation?.0 ?? 0.0)", longitude:  "\(currentLocation?.1 ?? 0.0)", id: communityId)
        APIProvider.shared.communityAPI.rx.request(.CommuntyDetail(param: param))
            .filterSuccessfulStatusCodes()
            .map(CommuintyDetailResponse.self)
            .subscribe(onSuccess: { value in
                if(value.statusCode <= 200){
                    self.setData(value.data)
                }
                self.dismissHUD()
            }, onError: { error in
                self.dismissHUD()
            })
            .disposed(by: disposeBag)
    }
    func initDetailNotice(_ communityId: Int){
        self.showHUD()
        let param = ComunityNoticeRequest(communityId: communityId)
        APIProvider.shared.communityAPI.rx.request(.CommuntyNotice(param: param))
            .filterSuccessfulStatusCodes()
            .map(CommunityNoticeResponse.self)
            .subscribe(onSuccess: { value in
                if(value.statusCode <= 200){
                    self.communityNotice = value.list ?? []
                    self.mainTableView.reloadData()
                }
                self.dismissHUD()
            }, onError: { error in
                self.dismissHUD()
            })
            .disposed(by: disposeBag)
    }
    func initDetailBoard(_ communityId: Int){
        self.showHUD()
        let param = ComunityNoticeRequest(communityId: communityId)
        APIProvider.shared.communityAPI.rx.request(.CommuntyBoard(param: param))
            .filterSuccessfulStatusCodes()
            .map(CommunityBoardResponse.self)
            .subscribe(onSuccess: { value in
                if(value.statusCode <= 200){
                    self.communityBoard = value.list ?? []
                    self.mainTableView.reloadData()
                }
                self.dismissHUD()
            }, onError: { error in
                self.dismissHUD()
            })
            .disposed(by: disposeBag)
    }
    func joinBoard(_ communityId: Int){
        self.showHUD()
        let param = JoinCommunity(communityId: communityId)
        APIProvider.shared.communityAPI.rx.request(.CommuntyJoin(param: param))
            .filterSuccessfulStatusCodes()
            .map(CommunityJoinResponse.self)
            .subscribe(onSuccess: { value in
                if(value.statusCode <= 200){
                    self.showToast(message: "신청되었습니다.")
                    self.joinButton.backgroundColor = .systemGray4
                    self.joinButton.tintColor = .white
                    self.joinButton.setTitle("신청중", for: .normal)
                    self.joinButton.isEnabled = false
                }
                self.dismissHUD()
            }, onError: { error in
                self.dismissHUD()
            })
            .disposed(by: disposeBag)
    }
    func initChatRoomList() {
      communityChat.removeAll()
      socketManager.getCommunityRoomList(type: "\(communityId)") { list in
        if list.count > 0 {
          for data in list {
              self.communityChat.append(ChatRoomData(dict: data))
          }
        }
      }
      socketManager.roomListUpdate { list in
        for data in list {
            self.communityChat.append(ChatRoomData(dict: data))
        }
        print(list)
      }
    }
    
    func setData(_ data: CommunityDetail){
        detaildata = data
        self.titleLabel.text = data.name
        self.contentLabel.text = data.content
        self.nameLabel.text = data.userName
        self.distanToMeLabel.text = "나와의 거리 \(data.distance)KM"
        self.peopleLabel.text = "참여인원 \(data.people)명"
        self.likeCountLabel.text = "\(data.likeCount)"
        self.disLikeLabel.text = "\(data.dislikeCount)"
        isStatus = data.isJoin
        authorityNotice = data.authorityNotice
        authorityBoard = data.authorityBoard
        authorityChat = data.authorityChat
        authorityDelete = data.authorityDelete
        self.isSecret = data.isSecret
        if isSecret{
            mainTableView.isScrollEnabled = false
        }
        self.isLike = data.isLike
        self.likeButtonState(state: data.isLike ?? false)
        self.disLikeButtonState(state: !(data.isLike ?? true))
        imageList = data.images
        imageCollectionView.reloadData()
        if imageList.isEmpty{
            thumbnailCountLabel.isHidden = true
        }else{
            thumbnailCountLabel.isHidden = false
            thumbnailCountLabel.text = "1/\(imageList.count)"
        }
        if data.isJoin {
            if data.joinStatus == "대기"{
                joinButton.isHidden = false
                self.joinButton.backgroundColor = .systemGray4
                self.joinButton.tintColor = .white
                self.joinButton.setTitle("신청중", for: .normal)
                self.joinButton.isEnabled = false
            }else if data.joinStatus == "참여"{
                joinButton.isHidden = false
                self.joinButton.setTitle("공지글 작성", for: .normal)
            }
        }else{
            joinButton.isHidden = false
        }
    }
    func likeButtonState(state: Bool){
        self.likeButton.image = state ? UIImage(named: "like") : UIImage(named: "likeoff")
        
    }
    func disLikeButtonState(state: Bool){
        self.dislikeButton.image = state ? UIImage(named: "dislike") : UIImage(named: "dislikeoff")
    }
    
    func registLike(isLike: Bool) {
        let param = ComunityLikeRequest(isLike: isLike, communityId: communityId)
        APIProvider.shared.communityAPI.rx.request(.CommuntyLike(param: param))
            .filterSuccessfulStatusCodes()
            .map(DefaultResponse.self)
            .subscribe(onSuccess: { value in
                
            }, onError: { error in
            })
            .disposed(by: disposeBag)
    }
    
    func removeLike() {
        APIProvider.shared.communityAPI.rx.request(.CommuntyDisLike(id: communityId))
            .filterSuccessfulStatusCodes()
            .map(DefaultResponse.self)
            .subscribe(onSuccess: { value in
                self.initDetailBoard(self.communityId)
            }, onError: { error in
            })
            .disposed(by: disposeBag)
    }
    @objc func showDialogPopupView(content:String) {
        let vc = DialogPopupView()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.delegate = self
        vc.titleString = "참여하기"
        vc.contentString = content
        vc.okbuttonTitle = "참여"
        vc.cancelButtonTitle = "취소"
        self.present(vc, animated: true, completion: nil)
    }
    
    func initrx(){
        
        joinButton.rx.tapGesture().when(.recognized)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.joinButton.currentTitle == "신청중"{
                }else{
                    if self.joinButton.titleLabel?.text == "공지글 작성"{
                        if !self.isStatus{
                            self.showDialogPopupView(content: "공지사항을 작성하기 위해서는 참여가 필요해요!")
                        }else{
                            let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityDetailRegisterVC") as! CommunityDetailRegisterVC
                            vc.communityId = self.communityId
                            vc.diff = self.selectedCategory
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else if self.joinButton.titleLabel?.text == "자유게시판 글 작성"{
                        if !self.isStatus{
                            self.showDialogPopupView(content: "자유게시판을 작성하기 위해서는 참여가 필요해요!")
                        }else{
                            let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityDetailRegisterVC") as! CommunityDetailRegisterVC
                            vc.communityId = self.communityId
                            vc.diff = self.selectedCategory
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else if self.joinButton.titleLabel?.text == "채팅방 만들기"{
                        if !self.isStatus{
                            self.showDialogPopupView(content: "해당 채팅방을 이용하기 위해서는 참여가 필요해요!")
                        }else{
                            let vc = RegistRoomVC.viewController()
                            vc.communityId = self.communityId
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else{
                        self.joinBoard(self.communityId)
                    }
                }
            }).disposed(by: disposeBag)
        
//        registerButton.rx.tapGesture().when(.recognized)
//            .bind(onNext: { [weak self] _ in
//                let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityDetailRegisterVC") as! CommunityDetailRegisterVC
//                vc.communityId = self!.communityId
//                vc.diff = self!.selectedCategory
//                self?.navigationController?.pushViewController(vc, animated: true)
//            }).disposed(by: disposeBag)
        likeButton.rx.tapGesture().when(.recognized)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.isLike == nil {
                    self.isLike = true
                    self.likeCountLabel.text = "\(Int(self.likeCountLabel.text ?? "0")! + 1)"
                    self.likeButtonState(state: true)
                    self.disLikeButtonState(state: false)
                    self.registLike(isLike: true)
                }else if self.isLike == false{
                    self.isLike = true
                    self.disLikeLabel.text = "\(Int(self.disLikeLabel.text ?? "0")! - 1)"
                    self.likeCountLabel.text = "\(Int(self.likeCountLabel.text ?? "0")! + 1)"
                    self.likeButtonState(state: true)
                    self.disLikeButtonState(state: false)
                    self.registLike(isLike: true)
                    
                } else {
                    self.isLike = nil
                    self.likeCountLabel.text = "\(Int(self.likeCountLabel.text ?? "0")! - 1)"
                    self.likeButtonState(state: false)
                    self.disLikeButtonState(state: false)
                }
            })
            .disposed(by: disposeBag)
        
        dislikeButton.rx.tapGesture().when(.recognized)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.isLike == nil {
                    self.isLike = false
                    self.disLikeLabel.text = "\(Int(self.disLikeLabel.text ?? "0")! + 1)"
                    self.likeButtonState(state: false)
                    self.disLikeButtonState(state: true)
                    self.registLike(isLike: false)
                    self.removeLike()
                }else if self.isLike == true{
                    self.isLike = false
                    self.likeCountLabel.text = "\(Int(self.likeCountLabel.text ?? "0")! - 1)"
                    self.disLikeLabel.text = "\(Int(self.disLikeLabel.text ?? "0")! + 1)"
                    self.likeButtonState(state: false)
                    self.disLikeButtonState(state: true)
                    self.registLike(isLike: false)
                } else {
                    self.isLike = nil
                    self.disLikeLabel.text = "\(Int(self.disLikeLabel.text ?? "0")! - 1)"
                    self.likeButtonState(state: false)
                    self.disLikeButtonState(state: false)
                }
            })
            .disposed(by: disposeBag)
    }
    @IBAction func tapMenu(_ sender: Any) {
        let vc = CommunityDetailMenuPopupVC.viewController()
        vc.isMine.onNext(self.isMine)
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
}
extension CommunityDetailVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension CommunityDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.isEqual(imageCollectionView) {
            let page = Int(targetContentOffset.pointee.x / imageCollectionView.bounds.width)
            print(page)
            
            thumbnailCountLabel.text = "\(page + 1)/\(imageList.count)"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == imageCollectionView) {
            if imageList.isEmpty{
                return 1
            }else{
                return imageList.count
            }
        } else{
            return category.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == imageCollectionView){
            if imageList.isEmpty{
                let cell = self.imageCollectionView.dequeueReusableCell(withReuseIdentifier: "Imagepager", for: indexPath)
                guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
                    return cell
                }
                thumbnail.image = UIImage(named: "noCommunityDetail")
                return cell
            }else{
                let dict = imageList[indexPath.row]
                let cell = self.imageCollectionView.dequeueReusableCell(withReuseIdentifier: "Imagepager", for: indexPath)
                guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
                    return cell
                }
                thumbnail.kf.setImage(with: URL(string: dict.name))
                return cell
            }
            
        }else {
            let cell = self.categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "DetailTapCell", for: indexPath)
            let dict = category[indexPath.row]
            guard let diffLabel = cell.viewWithTag(1) as? UILabel,
                  let selectedView = cell.viewWithTag(2)else {
                return cell
            }
            diffLabel.text = dict.rawValue
            if diffLabel.text == selectedCategory {
                diffLabel.textColor = .black
            }else{
                diffLabel.textColor = .lightGray
            }
            selectedView.isHidden = selectedCategory != dict.rawValue
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == imageCollectionView){
            return CGSize(width: APP_WIDTH(), height: collectionView.frame.size.height)
        }else{
            return CGSize(width: (APP_WIDTH()-10)/3, height: collectionView.frame.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == imageCollectionView){
            if imageList.isEmpty{
                
            }else{
                let vc = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "imageListScroll") as! ImageListWithScrolViewViewController
                vc.indexRow = indexPath.row
                var imageList: [UIImage] = []
                
                if self.imageList.count > 0 {
                    for i in 0..<self.imageList.count {
                        let dict = self.imageList[i]
                        do {
                            let data = try! Data(contentsOf: URL(string: dict.name)!)
                            let image = UIImage(data: data)
                            imageList.append(image!.resizeToWidth(newWidth: self.view.frame.width))
                        }
                    }
                }
                vc.imageList = imageList
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true)
            }
        }else{
            let dict = category[indexPath.row]
            selectedCategory = dict.rawValue
            categoryCollectionView.reloadData()
            if (selectedCategory == "공지사항") {
                initDetailNotice(communityId)
//                registerButton.isHidden = !authorityNotice
            }else if selectedCategory == "자유게시판" {
                initDetailBoard(communityId)
//                registerButton.isHidden = !authorityBoard
            }else{
                initDetailBoard(communityId)
//                registerButton.isHidden = !authorityChat
            }
            if detaildata?.joinStatus == "참여"{
                if (selectedCategory == "공지사항") {
                    joinButton.setTitle("공지글 작성", for: .normal)
                }else if selectedCategory == "자유게시판" {
                    joinButton.setTitle("자유게시판 글 작성", for: .normal)
                }else{
                    joinButton.setTitle("채팅방 만들기", for: .normal)
                }
            }
        }
    }
}
extension CommunityDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSecret {
            return 1
            
        }else if selectedCategory == "공지사항"{
            if communityNotice.isEmpty{
                return 1
            }else{
                return communityNotice.count
            }
        }else if selectedCategory == "자유게시판"{
            if communityBoard.isEmpty{
                return 1
            }else{
                return communityBoard.count
            }
        }else{
            if communityChat.isEmpty{
                return 1
            }else{
                return communityChat.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSecret{
            let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noList", for: indexPath)
            guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
                return cell
            }
            thumbnail.image = UIImage(named: "communitySecret")
            return cell
        } else if selectedCategory == "공지사항" {
            if communityNotice.isEmpty{
                let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noList", for: indexPath)
                guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
                    return cell
                }
                thumbnail.image = UIImage(named: "noNotice")
                return cell
            }else{
                let dict = communityNotice[indexPath.row]
                let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath)
                guard let titleLabel = cell.viewWithTag(1) as? UILabel,
                      let contentLabel = cell.viewWithTag(2) as? UILabel,
                      let likeLabel = cell.viewWithTag(3) as? UILabel,
                      let dislikeLabel = cell.viewWithTag(4) as? UILabel,
                      let dateLabel = cell.viewWithTag(5) as? UILabel else {
                    return cell
                }
                titleLabel.text = dict.title
              contentLabel.text = dict.user.name
                likeLabel.text = "좋아요 \(dict.likeCount)"
                dislikeLabel.text = "싫어요 \(dict.dislikeCount)"
                dateLabel.text = dict.createdAt
                return cell
            }
        } else if selectedCategory == "자유게시판"{
            if communityBoard.isEmpty{
                let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noList", for: indexPath)
                guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
                    return cell
                }
                thumbnail.image = UIImage(named: "noPost")
                return cell
            }else{
                let dict = communityBoard[indexPath.row]
                let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath)
                guard let titleLabel = cell.viewWithTag(1) as? UILabel,
                      let contentLabel = cell.viewWithTag(2) as? UILabel,
                      let likeLabel = cell.viewWithTag(3) as? UILabel,
                      let dislikeLabel = cell.viewWithTag(4) as? UILabel,
                      let dateLabel = cell.viewWithTag(5) as? UILabel else {
                    return cell
                }
                titleLabel.text = dict.title
              contentLabel.text = dict.user.name
                likeLabel.text = "좋아요 \(dict.likeCount)"
                likeLabel.text = "싫어요 \(dict.dislikeCount)"
                dateLabel.text = dict.createdAt
                
                return cell
                
            }
        }else{
            if communityChat.isEmpty{
                let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "noList", for: indexPath)
                guard let thumbnail = cell.viewWithTag(1) as? UIImageView else {
                    return cell
                }
                thumbnail.image = UIImage(named: "noChat")
                return cell
            }else{
                let dict = communityChat[indexPath.row]
                let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "chattingCell", for: indexPath)
                guard let thumbnail = cell.viewWithTag(1) as? UIImageView,
                      let titleLabel = cell.viewWithTag(2) as? UILabel,
                      let peopleLabel = cell.viewWithTag(3) as? UILabel,
                      let dateLabel = cell.viewWithTag(4) as? UILabel,
                      let contentLabel = cell.viewWithTag(5) as? UILabel else {
                    return cell
                }
                if dict.thumbnail != "default"{
                    thumbnail.kf.setImage(with: URL(string: dict.thumbnail ?? ""))
                }
                titleLabel.text = dict.name
                peopleLabel.text = "\(dict.userCount!)명 참여중"
                dateLabel.text = dict.updatedAt
                contentLabel.text = dict.message
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSecret{
            
        }else if selectedCategory == "공지사항"{
            if communityNotice.isEmpty{
            }else{
                let dict = communityNotice[indexPath.row]
                let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityInfoDetailVC") as! CommunityInfoDetailVC
                vc.naviTitle = selectedCategory
                vc.detailId = dict.id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if selectedCategory == "자유게시판"{
            if communityNotice.isEmpty{
                
            }else{
                let dict = communityBoard[indexPath.row]
                let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityInfoDetailVC") as! CommunityInfoDetailVC
                vc.naviTitle = selectedCategory
                vc.detailId = dict.id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let dict = communityChat[indexPath.row]
            let vc = ChatVC.viewController()
            vc.communityId = self.communityId
            vc.chatRoomId = dict.id ?? 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSecret{
            return 162
        }else if selectedCategory == "공지사항"{
            if communityNotice.isEmpty{
                return 162
            }else{
                return 80
            }
        }else if selectedCategory == "자유게시판"{
            if communityBoard.isEmpty{
                return 162
            }else{
                return 80
            }
        }else{
            if communityChat
                .isEmpty{
                return 162
            }else{
                return 100
            }
        }
    }
    
}

