//
//  MyCommunityRegisterVC.swift
//  PlayAround
//
//  Created by 이남기 on 2022/07/06.
//

import Foundation
import UIKit
import Photos
import DKImagePickerController

class MyCommunityRegisterVC: BaseViewController{
  @IBOutlet weak var mainTableView: UITableView!
  @IBOutlet weak var uploadImageCollectionView: UICollectionView!
  @IBOutlet weak var selectCategoryCollectionView: UICollectionView!
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var tapOff: UIButton!
  @IBOutlet weak var tapOn: UIButton!
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var contentTextField: UITextField!
  
  let categoryList: [CommunityCategory] = [ .아파트별모임, .스터디그룹, .동호회, .맘카페, .기타]
  var selectedCategory: CommunityCategory = .아파트별모임
  var selectIndex: Int?
  
  var villageList : [village] = []
  var selectSecret: Bool = false
  var selectVillageId : Int?
  
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
    setUploadImageCollectionViewLayout()
    initrx()
  }
  
  
  func setUploadImageCollectionViewLayout() {
    uploadImageCollectionView.dataSource = self
    uploadImageCollectionView.delegate = self
    
    selectCategoryCollectionView.register(UINib(nibName: "CollectionViewImageCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewImageCell")
    selectCategoryCollectionView.dataSource = self
    selectCategoryCollectionView.delegate = self
    mainTableView.layoutTableHeaderView()
    
    mainTableView.delegate = self
    mainTableView.dataSource = self
    
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
    layout2.itemSize = CGSize(width: 65, height: 65)
    layout2.minimumInteritemSpacing = 0
    layout2.minimumLineSpacing = 0
    layout2.invalidateLayout()
    layout2.scrollDirection = .horizontal
    selectCategoryCollectionView.collectionViewLayout = layout2
    
    tapOn.backgroundColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686276317, alpha: 1)
    tapOn.tintColor = #colorLiteral(red: 0.5607842803, green: 0.5607842803, blue: 0.5607843399, alpha: 1)
    tapOff.backgroundColor = #colorLiteral(red: 0.9704249501, green: 0.5212578773, blue: 0.1708718836, alpha: 1)
    tapOff.tintColor = .white
    
    initVillageList()
  }
  func registerCommunity(){
    print(uploadImages.count)
    if titleTextField.text!.isEmpty {
      callOkActionMSGDialog(message: "커뮤니티명을 입력해주세요."){
      }
      return
    }
    if contentTextField.text!.isEmpty {
      callOkActionMSGDialog(message: "한줄 설명을 입력해주세요."){
      }
      return
    }
    if selectVillageId == nil {
      callOkActionMSGDialog(message: "동네를 선택해주세요."){
      }
      return
    }
    self.showHUD()
    APIProvider.shared.communityAPI.rx.request(.CommuntyRegister(param: RegistCommunityRegister(isSecret: selectSecret, name: titleTextField.text!, content: contentTextField.text!, villageId: selectVillageId!, category: selectedCategory.rawValue)))
      .filterSuccessfulStatusCodes()
      .map(DefaultIDResponse.self)
      .subscribe(onSuccess: { value in
        if(value.statusCode <= 200){
          let id = value.data?.id ?? 0

          if self.uploadImages.count != 0{
            self.uploadIamgeList(communityId: id , success: {
              self.dismissHUD()
              self.callOkActionMSGDialog(message: "등록되었습니다.") {
                self.backPress()
              }
            })
          }else{
            self.callOkActionMSGDialog(message: "등록되었습니다.") {
              self.backPress()
            }
          }
        }
        self.dismissHUD()
      }, onError: { error in
        self.dismissHUD()
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
        self.registerCommunity()
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
extension MyCommunityRegisterVC: UICollectionViewDelegate, UICollectionViewDataSource {
  
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
    }else{
      let dict = categoryList[indexPath.row]
      selectedCategory = dict
      selectCategoryCollectionView.reloadData()
    }
  }
}
extension MyCommunityRegisterVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return villageList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectIndex = indexPath.row
    selectVillageId = villageList[indexPath.row].id
    mainTableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 51
    
  }
  
}
