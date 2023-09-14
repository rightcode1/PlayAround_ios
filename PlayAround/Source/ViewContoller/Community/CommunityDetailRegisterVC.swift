//
//  CommunityDetailRegisterVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/06/05.
//

import Foundation
import UIKit
import Photos
import DKImagePickerController

class CommunityDetailRegisterVC:BaseViewController, tapRegister{
    func vote(list: [Choices], endDate: String, title: String, overlap: Bool) {
        voteData = CommunityVote(communityNoticeId: 0, title: title, endDate: endDate, overlap: overlap, choices: list.map{Choice.init(content: $0.content)})
    }
    
  @IBOutlet weak var uploadImageCollectionView: UICollectionView!
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var contentTextVIew: UITextView!
    @IBOutlet weak var contentPlaceHolder: UILabel!
    @IBOutlet weak var registerButton: UIButton!
  
  var communityId: Int = 0
  var diff: String = ""
  var imageList: [Image] = []
  var uploadImages: [UIImage] = [] {
    didSet {
      uploadImageCollectionView.reloadData()
    }
  }
    var voteData: CommunityVote?
  var detailImagesCount: Int?
  var removeImageIdList: [Int] = []
  
  
  var exportManually = false
  let pickerController = DKImagePickerController()
  var assets: [DKAsset]?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUploadImageCollectionViewLayout()
    initrx()
  }
  func setUploadImageCollectionViewLayout() {
    uploadImageCollectionView.dataSource = self
    uploadImageCollectionView.delegate = self
    
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    
    layout.itemSize = CGSize(width: 55, height: 55)
    layout.minimumInteritemSpacing = 15
    layout.minimumLineSpacing = 15
    layout.invalidateLayout()
    layout.scrollDirection = .horizontal
    uploadImageCollectionView.collectionViewLayout = layout
  }
  
  override func viewWillAppear(_ animated: Bool) {
//    self.navigationController?.navigationBar.isHidden = true
    
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
//    self.navigationController?.navigationBar.isHidden = false
  }
  
  
  func initRegister() {
    self.showHUD()
    let param = RegistCommunityBoard(communityId: communityId, title: titleTextField.text!, content: contentTextVIew.text)
    APIProvider.shared.communityAPI.rx.request(.RegistCommunityBoard(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultIDResponse.self)
      .subscribe(onSuccess: { value in
        self.uploadBoardIamgeList(communityId: value.data?.id ?? 0, success: {
          self.dismissHUD()
          self.callOkActionMSGDialog(message: "등록되었습니다") {
            self.backPress()
          }
        })
        self.dismissHUD()
      }, onError: { error in
        self.callOkActionMSGDialog(message: "권한이 없습니다") {
        }
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  func initNoticeRegister() {
    self.showHUD()
    let param = RegistCommunityBoard(communityId: communityId, title: titleTextField.text!, content: contentTextVIew.text)
    APIProvider.shared.communityAPI.rx.request(.RegistCommunityNotice(param: param))
      .filterSuccessfulStatusCodes()
      .map(DefaultIDResponse.self)
      .subscribe(onSuccess: { value in
          if self.voteData != nil{
              self.initNoticeVoteRegister(communityId: value.data?.id ?? 0)
          }else{
              self.uploadIamgeList(communityId: value.data?.id ?? 0, success: {
              self.dismissHUD()
              self.callOkActionMSGDialog(message: "등록되었습니다") {
                self.backPress()
              }
            })
          }
        self.dismissHUD()
      }, onError: { error in
        self.callOkActionMSGDialog(message: "권한이 없습니다") {
          
        }
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
    func initNoticeVoteRegister(communityId:Int) {
      self.showHUD()
        voteData?.communityNoticeId = communityId
        APIProvider.shared.communityAPI.rx.request(.RegistCommunityNoticeVote(param: voteData!))
        .filterSuccessfulStatusCodes()
        .map(DefaultIDResponse.self)
        .subscribe(onSuccess: { value in
            self.uploadIamgeList(communityId: value.data?.id ?? 0, success: {
            self.dismissHUD()
            self.callOkActionMSGDialog(message: "등록되었습니다") {
              self.backPress()
            }
          })
            
          self.dismissHUD()
        }, onError: { error in
          self.callOkActionMSGDialog(message: "권한이 없습니다") {
            
          }
          self.dismissHUD()
        })
        .disposed(by: disposeBag)
    }
    
  
  func uploadIamgeList(communityId: Int, success: @escaping () -> Void) {
    if uploadImages.isEmpty {
      success()
    } else {
      APIProvider.shared.communityAPI.rx.request(.imageNoticeRegister(communityId: communityId, imageList: uploadImages.map({ $0 })))
        .filterSuccessfulStatusCodes()
        .subscribe(onSuccess: { response in
          success()
        }, onError: { error in
          success()
        })
        .disposed(by: disposeBag)
    }
  }
    func uploadBoardIamgeList(communityId: Int, success: @escaping () -> Void) {
      if uploadImages.isEmpty {
        success()
      } else {
        APIProvider.shared.communityAPI.rx.request(.imageBoardRegister(communityId: communityId, imageList: uploadImages.map({ $0 })))
          .filterSuccessfulStatusCodes()
          .subscribe(onSuccess: { response in
            success()
          }, onError: { error in
            success()
          })
          .disposed(by: disposeBag)
      }
    }
  
  func showImagePicker() {
    if self.exportManually {
      DKImageAssetExporter.sharedInstance.add(observer: self)
    }
    
    if let assets = self.assets {
      pickerController.select(assets: assets)
    }
    
    pickerController.exportStatusChanged = { status in
      switch status {
      case .exporting:
        print("exporting")
      case .none:
        print("none")
      }
    }
    
    pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
      self.updateAssets(assets: assets)
    }
    
    pickerController.modalPresentationStyle = .formSheet
    
    if pickerController.UIDelegate == nil {
      pickerController.UIDelegate = AssetClickHandler()
    }
    
    self.present(pickerController, animated: true) {}
  }
  @objc
  func deleteAsset(_ sender: UIButton) {
    if let index = Int(sender.accessibilityHint!) {
      let asset = assets![index - 1]
      assets?.remove(at: index - 1)

      pickerController.deselect(asset: asset)
      pickerController.removeSelection(asset: asset)
      
      DKImageAssetExporter.sharedInstance.exportAssetsAsynchronously(assets: assets ?? [], completion: nil)
      
      uploadImages.remove(at: index - 1)
      uploadImageCollectionView.reloadData()
    }
  }
  func deleteImage(_ sender: UIButton) {
    if let index = Int(sender.accessibilityHint!) {
      let dict = imageList[index]
      removeImageIdList.append(dict.id)
      if (detailImagesCount ?? 0) > 0 {
        detailImagesCount = (detailImagesCount ?? 0) - 1
      } else {
        detailImagesCount = 0
      }
      
      pickerController.maxSelectableCount = 6 - (detailImagesCount ?? 0)
      imageList.remove(at: index)
      uploadImageCollectionView.reloadData()
    }
  }
  func updateAssets(assets: [DKAsset]) {
    print("didSelectAssets")
    self.uploadImages.removeAll()
    
    self.assets = assets
    self.uploadImageCollectionView.reloadData()
    
    if pickerController.exportsWhenCompleted {
      for asset in assets {
        if let error = asset.error {
          print("exporterDidEndExporting with error:\(error.localizedDescription)")
        } else {
          print("exporterDidEndExporting:\(asset.localTemporaryPath!)")
        }
      }
    }
    
    DispatchQueue.global().sync {
      for asset in assets {
        asset.fetchOriginalImage { (image, nil) in
          self.uploadImages.append(image!)
          self.uploadImageCollectionView.reloadData()
          print("self.uploadImages : \(self.uploadImages.count)")
        }
      }
    }
    
    if self.exportManually {
      DKImageAssetExporter.sharedInstance.exportAssetsAsynchronously(assets: assets, completion: nil)
    }
    
    print("self.assets : \(self.assets?.count ?? 0)")
  }
  
  @IBAction func tapVote(_ sender: Any) {
    let vc = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityVoteVC") as! CommunityVoteVC
      vc.delegate = self
    self.navigationController?.pushViewController(vc, animated: true)
  }
  func initrx(){
    contentTextVIew.rx.text.orEmpty
        .bind(onNext: { [weak self] text in
          self?.contentPlaceHolder.isHidden = !text.isEmpty
        })
        .disposed(by: disposeBag)
    registerButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if self.diff == "자유게시판"{
          self.initRegister()
        }else{
          self.initNoticeRegister()
        }
      }).disposed(by: disposeBag)
  }
}
extension CommunityDetailRegisterVC: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 3
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return uploadImages.count
    } else {
      return imageList.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.section == 0 {
      let cell = uploadImageCollectionView.dequeueReusableCell(withReuseIdentifier: "registPhotoCell", for: indexPath)
      return cell
    } else if indexPath.section == 1 {
      let cell = uploadImageCollectionView.dequeueReusableCell(withReuseIdentifier: "imageListCell", for: indexPath)
      print("section 1 - indexPath.row : \(indexPath.row)")
      guard let imageView = cell.viewWithTag(1) as? UIImageView else { return cell }
      
      let image = uploadImages[indexPath.row]
      imageView.image = image
      
      //        asset.fetchOriginalImage { (image, nil) in
      //          imageView.image = image
      //        }
      
      return cell
    } else {
      let cell = uploadImageCollectionView.dequeueReusableCell(withReuseIdentifier: "modifyImageListCell", for: indexPath)
      
      guard let imageView = cell.viewWithTag(1) as? UIImageView else { return cell }
      
      let dict = imageList[indexPath.row]
      imageView.kf.setImage(with: URL(string: dict.name))
      
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
    if indexPath.section == 0 {
      showImagePicker()
    } else if indexPath.section == 1 {
      assets?.remove(at: indexPath.row)
      uploadImages.remove(at: indexPath.row)
      uploadImageCollectionView.reloadData()
    } else {
      let dict = imageList[indexPath.row]
      removeImageIdList.append(dict.id)
      if (detailImagesCount ?? 0) > 0 {
        detailImagesCount = (detailImagesCount ?? 0) - 1
      } else {
        detailImagesCount = 0
      }
      
      pickerController.maxSelectableCount = 6 - (detailImagesCount ?? 0)
      imageList.remove(at: indexPath.row)
      uploadImageCollectionView.reloadData()
    }
  }
}
