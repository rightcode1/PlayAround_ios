//
//  MyCommunitiyUpdateVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/07/08.
//

import Foundation

import Foundation
import UIKit
import Photos
import DKImagePickerController

enum AdminCommunity: String, Codable {
  case permission = "권한 관리"
  case admin = "신청 관리"
  case update = "정보수정"
}

class MyCommunitiyUpdateVC: BaseViewController,ViewControllerFromStoryboard{
  @IBOutlet weak var menuCollectionView: UICollectionView!
  @IBOutlet weak var adminMainTableView: UITableView!
  @IBOutlet weak var mainTableView: UITableView!
  @IBOutlet weak var uploadImageCollectionView: UICollectionView!
  @IBOutlet weak var selectCategoryCollectionView: UICollectionView!
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var tapOff: UIButton!
  @IBOutlet weak var tapOn: UIButton!
  
  var communityId: Int = 0

  
  private let diffList: [AdminCommunity] = [.permission, .admin, .update]
  private var selectedDiff: AdminCommunity = .permission
  
  let categoryList: [CommunityCategory] = [.아파트별모임, .스터디그룹, .동호회, .맘카페, .기타]
  var selectedCategory: CommunityCategory = .아파트별모임
  
  var checkHidden: Bool = false
  
  var selectIndex: Int?
  
  var villageList : [village] = []
  var communityJoiner : [CommunityJoiner] = []
  
  var selectCommunityOn = ""
  var imageList: [Image] = []
  var uploadImages: [UIImage] = [] {
    didSet {
      uploadImageCollectionView.reloadData()
    }
  }
  
  var detailImagesCount: Int?
  var removeImageIdList: [Int] = []
  
  var exportManually = false
  let pickerController = DKImagePickerController()
  var assets: [DKAsset]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    delegate()
    initrx()
  }
  static func viewController() -> MyCommunitiyUpdateVC {
    let viewController = MyCommunitiyUpdateVC.viewController(storyBoardName: "Setting")
    return viewController
  }
  func delegate(){
    uploadImageCollectionView.dataSource = self
    uploadImageCollectionView.delegate = self
    
    selectCategoryCollectionView.register(UINib(nibName: "CollectionViewImageCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewImageCell")
    
    selectCategoryCollectionView.dataSource = self
    selectCategoryCollectionView.delegate = self
    
    menuCollectionView.dataSource = self
    menuCollectionView.delegate = self
    
    
    adminMainTableView.delegate = self
    adminMainTableView.dataSource = self
    
    
    mainTableView.delegate = self
    mainTableView.dataSource = self
    CollectionSize()
  }
  
  func CollectionSize() {
    
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    
    layout.itemSize = CGSize(width: 55, height: 55)
    layout.minimumInteritemSpacing = 15
    layout.minimumLineSpacing = 15
    layout.invalidateLayout()
    layout.scrollDirection = .horizontal
    uploadImageCollectionView.collectionViewLayout = layout
    
    let layout2 = UICollectionViewFlowLayout()
    layout2.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    layout2.itemSize = CGSize(width: 55, height: 55)
    layout2.minimumInteritemSpacing = 0
    layout2.minimumLineSpacing = 0
    layout2.invalidateLayout()
    layout2.scrollDirection = .horizontal
    selectCategoryCollectionView.collectionViewLayout = layout2
    
    
    let layout3 = UICollectionViewFlowLayout()
    layout3.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    let width = textWidth(text: selectedDiff.rawValue, font: .systemFont(ofSize: 12, weight: .medium)) + 18
    layout3.itemSize = CGSize(width: width, height: 30)
    layout3.minimumInteritemSpacing = 0
    layout3.minimumLineSpacing = 0
    layout3.invalidateLayout()
    layout3.scrollDirection = .horizontal
    menuCollectionView.collectionViewLayout = layout3
    initCommunityList()
    initVillageList()
  }
  
  func initVillageList(){
    self.showHUD()
    APIProvider.shared.villageAPI.rx.request(.villageList(param: VillageListRequest(latitude: "\(currentLocation?.0 ?? 0.0)", longitude: "\(currentLocation?.1 ?? 0.0)", isMyVillage: "true")))
      .filterSuccessfulStatusCodes()
      .map(VillageListResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          print("\(value.list)")
          self.villageList = value.list
          self.mainTableView.reloadData()
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
      })
      .disposed(by: disposeBag)
  }
  
  
  func initCommunityList() {
    APIProvider.shared.communityAPI.rx.request(.CommunityJoinerList(param: JoinCommunity(communityId: communityId)))
      .filterSuccessfulStatusCodes()
      .map(CommunityJoinerResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          print("!!!")
        self.communityJoiner = value.list
        self.adminMainTableView.reloadData()
        }
      }, onError: { error in
      })
      .disposed(by: disposeBag)
  }
  
  func uploadIamgeList(communityId: Int, success: @escaping () -> Void) {
    if uploadImages.isEmpty {
      success()
    } else {
      APIProvider.shared.communityAPI.rx.request(.imageRegister(communityId: communityId, imageList: uploadImages.map({ $0 })))
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
  
  func initrx(){
    registerButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        //        self.initRegister()
      }).disposed(by: disposeBag)
    
    tapOn.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        
        if self.tapOn.backgroundColor == #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686276317, alpha: 1){
          self.tapOn.backgroundColor = #colorLiteral(red: 0.9704249501, green: 0.5212578773, blue: 0.1708718836, alpha: 1)
          self.tapOn.tintColor = .white
          self.tapOff.backgroundColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686276317, alpha: 1)
          self.tapOff.tintColor = #colorLiteral(red: 0.5607842803, green: 0.5607842803, blue: 0.5607843399, alpha: 1)
        }else{
          self.tapOn.backgroundColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686276317, alpha: 1)
          self.tapOn.tintColor = #colorLiteral(red: 0.5607842803, green: 0.5607842803, blue: 0.5607843399, alpha: 1)
          self.tapOff.backgroundColor = #colorLiteral(red: 0.9704249501, green: 0.5212578773, blue: 0.1708718836, alpha: 1)
          self.tapOff.tintColor = .white
          
        }
      }).disposed(by: disposeBag)
    
    tapOff.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        if self.tapOff.backgroundColor == #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686276317, alpha: 1){
          self.tapOn.backgroundColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686276317, alpha: 1)
          self.tapOn.tintColor = #colorLiteral(red: 0.5607842803, green: 0.5607842803, blue: 0.5607843399, alpha: 1)
          self.tapOff.backgroundColor = #colorLiteral(red: 0.9704249501, green: 0.5212578773, blue: 0.1708718836, alpha: 1)
          self.tapOff.tintColor = .white
          
        }else{
          self.tapOn.backgroundColor = #colorLiteral(red: 0.9704249501, green: 0.5212578773, blue: 0.1708718836, alpha: 1)
          self.tapOn.tintColor = .white
          self.tapOff.backgroundColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686276317, alpha: 1)
          self.tapOff.tintColor = #colorLiteral(red: 0.5607842803, green: 0.5607842803, blue: 0.5607843399, alpha: 1)
          
        }
      }).disposed(by: disposeBag)
  }
}
extension MyCommunitiyUpdateVC: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if collectionView.isEqual(uploadImageCollectionView){
      return 3
    }else{
      return 1
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    if collectionView.isEqual(uploadImageCollectionView){
      if section == 0 {
        return 1
      } else if section == 1 {
        return uploadImages.count
      } else {
        return imageList.count
      }
    }else if collectionView.isEqual(menuCollectionView){
      return diffList.count
    }else{
      return categoryList.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView.isEqual(uploadImageCollectionView){
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
    }else if collectionView.isEqual(menuCollectionView){
      let cell = menuCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      let dict = diffList[indexPath.row]
      
      let selectedTextColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
      let defaultTextColor = UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0)
      
      (cell.viewWithTag(1) as! UILabel).text = dict.rawValue
      (cell.viewWithTag(1) as! UILabel).textColor = dict != selectedDiff ? defaultTextColor : selectedTextColor
      
      (cell.viewWithTag(2)!).isHidden = dict != selectedDiff
      
      
      switch selectedDiff {
      case .admin:
        mainTableView.isHidden = true
        adminMainTableView.isHidden = false
        checkHidden = true
        self.initCommunityList()
      case .permission:
        mainTableView.isHidden = true
        adminMainTableView.isHidden = false
        checkHidden = false
        self.initCommunityList()
      case .update:
        mainTableView.isHidden = false
        adminMainTableView.isHidden = true
        self.initVillageList()
      }
      
      return cell
    }else{
      let cell = selectCategoryCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewImageCell", for: indexPath) as! CollectionViewImageCell
      let dict = categoryList[indexPath.row]
      cell.imageView.image = selectedCategory == dict ? dict.onImage() : dict.offImage()
      
      
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
    if collectionView.isEqual(uploadImageCollectionView){
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
    }else if collectionView.isEqual(menuCollectionView){
      let dict = diffList[indexPath.row]
      selectedDiff = dict
      menuCollectionView.reloadData()
    }else{
      let dict = categoryList[indexPath.row]
      selectedCategory = dict
      selectCategoryCollectionView.reloadData()
    }
  }
}
extension MyCommunitiyUpdateVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == adminMainTableView{
      return communityJoiner.count
    }else{
      return villageList.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if tableView == adminMainTableView{
      let cell = self.adminMainTableView.dequeueReusableCell(withIdentifier: "joinerCell", for: indexPath) as! AdminCommunityCell
      let dict = communityJoiner[indexPath.row]
      cell.checkBool = [dict.authorityNotice,dict.authorityBoard,dict.authorityChat,dict.authorityDelete]
      cell.initdelegate(checkHidden)
      cell.MyCommunitiyUpdateVC = self
      cell.initdata(dict,indexPath,status: dict.status)
      if checkHidden{
        cell.tapOnOff.isHidden = false
      }else{
        cell.tapOnOff.isHidden = true
      }
      return cell
    }else{
      let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "villageCell", for: indexPath)
      guard let address = cell.viewWithTag(1) as? UILabel,
            let check = cell.viewWithTag(2) as? UIImageView else {
              return cell
            }
      if indexPath.row != selectIndex{
        villageList[indexPath.row].isselect = false
      }else{
        villageList[indexPath.row].isselect = true
      }
      let dict = villageList[indexPath.row]
      address.text = dict.address
      check.image = dict.isselect ?? false ? UIImage(named: "checkOn") : UIImage(named: "checkOff")
      
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView == adminMainTableView{
    }else{
      selectIndex = indexPath.row
      mainTableView.reloadData()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if tableView == adminMainTableView{
      if checkHidden {
        return 75
      }else{
        return 97.5
      }
    }else{
      return 51
    }
    
  }
  
}
