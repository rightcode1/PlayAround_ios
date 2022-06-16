//
//  RegistUsedVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/16.
//

import UIKit
import RxSwift
import Photos
import DKImagePickerController

class RegistUsedVC: BaseViewController, ViewControllerFromStoryboard {
  
  @IBOutlet weak var categoryCollectionView: UICollectionView! {
    didSet {
      setCategoryCollectionView()
    }
  }
  
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var priceTextField: UITextField!
  
  @IBOutlet weak var contentTextView: UITextView!
  @IBOutlet weak var contentTextViewPlaceHolder: UILabel!
  
  @IBOutlet weak var setHashTagButton: UIView!
  @IBOutlet weak var hashtagTextView: UITextView!
  @IBOutlet weak var hashtagTextViewPlaceHolder: UILabel!
  
  @IBOutlet weak var uploadImageCollectionView: UICollectionView!
  
  @IBOutlet weak var registButton: UIButton!
  
  var usedId: Int?
  
  let categoryList: [UsedCategory] = [.전체, .육아, .골프, .서적, .가전, .IT, .소형가전]
  var selectedCategory: UsedCategory?
  
  var hashtag: [String] = []
  
  let pickerController = DKImagePickerController()
  var assets: [DKAsset]?
  var exportManually = false
  
  var uploadImages: [UIImage] = [] {
    didSet {
      uploadImageCollectionView.reloadData()
    }
  }
  
  var imageList: [Image] = []
  var removeImageIdList: [Int] = []
  var detailImagesCount: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  func setCategoryCollectionView() {
    categoryCollectionView.dataSource = self
    categoryCollectionView.delegate = self
    categoryCollectionView.register(UINib(nibName: "CollectionViewImageCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewImageCell")
    
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    layout.itemSize = CGSize(width: 45, height: 60)
    layout.minimumInteritemSpacing = 12
    layout.minimumLineSpacing = 12
    layout.scrollDirection = .horizontal
    layout.invalidateLayout()
    categoryCollectionView.collectionViewLayout = layout
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
  
}

extension RegistUsedVC: HashtagListVCDelegate {
  func setHashtag(selectHashtag: [String]) {
    hashtag = selectHashtag
    hashtagTextView.text = hashtag.map({ "#\($0)" }).joined(separator: " ")
    hashtagTextViewPlaceHolder.isHidden = true
  }
}

extension RegistUsedVC: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if uploadImageCollectionView == collectionView {
      return 3
    } else {
      return 1
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if categoryCollectionView == collectionView {
      return categoryList.count
    } else {
      if section == 0 {
        return 1
      } else if section == 1 {
        return uploadImages.count
      } else {
        return imageList.count
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if categoryCollectionView == collectionView {
      let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      guard let imageView = cell.viewWithTag(1) as? UIImageView else { return cell }
      
      let dict = categoryList[indexPath.row]
      
      imageView.image = selectedCategory == dict ? dict.onRegistImage() : dict.offRegistImage()
      
      return cell
    } else {
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
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
    if categoryCollectionView == collectionView {
      let dict = categoryList[indexPath.row]
      selectedCategory = dict
      categoryCollectionView.reloadData()
    } else {
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
}
