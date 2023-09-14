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
  
  let categoryList: [UsedCategory] = [.육아, .골프, .서적, .가전, .IT, .소형가전]
  var selectedCategory: UsedCategory?
  
  var hashtag: [String] = []
  
  let pickerController = DKImagePickerController()
  var assets: [DKAsset]?
  var exportManually = false
    var updateDetail: UsedDetailData?
  
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
    if usedId != nil{
        initUsedDetail()
    }
    setCollectionViews()
    bindInput()
  }
  
  static func viewController() -> RegistUsedVC {
    let viewController = RegistUsedVC.viewController(storyBoardName: "Used")
    return viewController
  }
  
  func setCollectionViews() {
    setCategoryCollectionView()
    setUploadImageCollectionViewLayout()
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
    priceTextField.delegate = self
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
    func initUsedDetail() {
      self.showHUD()
      APIProvider.shared.usedAPI.rx.request(.detail(id: usedId ?? 0))
        .filterSuccessfulStatusCodes()
        .map(UsedDetailResponse.self)
        .subscribe(onSuccess: { value in
          guard let data = value.data else { return }
            for count in 0 ..< (value.data?.images.count ?? 0){
                let url = URL(string: value.data?.images[count].name ?? "")
                    if let data = try? Data(contentsOf: url!)
                    {
                        let image: UIImage = UIImage(data: data)!
                        self.uploadImages.append(image)
                        self.uploadImageCollectionView.reloadData()
                    }
            }
            self.selectedCategory = data.category
            self.categoryCollectionView.reloadData()
            self.titleTextField.text = data.name
            self.contentTextView.text = data.content
            self.hashtag = data.hashtag
            self.hashtagTextView.text = self.hashtag.map({ "#\($0)" }).joined(separator: " ")
            self.hashtagTextViewPlaceHolder.isHidden = true
            self.priceTextField.text = data.price.formattedProductPrice()
            self.registButton.setTitle("수정하기", for: .normal)
          
          self.dismissHUD()
        }, onError: { error in
          self.dismissHUD()
        })
        .disposed(by: disposeBag)
    }
  
  func registFood() {
    guard let selectedCategory = selectedCategory else {
      showToast(message: "카테고리를 선택해주세요.")
      return
    }
    
    guard !titleTextField.text!.isEmpty else {
      showToast(message: "제목 입력해주세요.")
      return
    }
    
    guard !priceTextField.text!.isEmpty else {
      showToast(message: "가격을 입력해주세요.")
      return
    }
    
    guard !contentTextView.text!.isEmpty else {
      showToast(message: "내용을 입력해주세요.")
      return
    }
    
    let param = RegistUsedRequest(
      category: selectedCategory,
      name: titleTextField.text!,
      content: contentTextView.text!,
      price: Int(priceTextField.text?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0,
      villageId: DataHelperTool.villageId ?? 0,
      hashtag: hashtag
    )
    
    showHUD()
    
    if let usedId = self.usedId { // 수정
      APIProvider.shared.usedAPI.rx.request(.update(id: usedId, param: param))
        .filterSuccessfulStatusCodes()
        .subscribe(onSuccess: { response in
          self.uploadIamgeList(usedId: usedId, success: {
            self.dismissHUD()
            self.callOkActionMSGDialog(message: "수정되었습니다") {
              self.backPress()
            }
          })
          
        }, onError: { error in
          self.dismissHUD()
          self.callMSGDialog(message: "오류가 발생하였습니다")
        })
        .disposed(by: disposeBag)
    } else { // 생성
      APIProvider.shared.usedAPI.rx.request(.register(param: param))
        .filterSuccessfulStatusCodes()
        .map(DefaultIDResponse.self)
        .subscribe(onSuccess: { response in
          let id = response.data?.id ?? 0
          self.uploadIamgeList(usedId: id, success: {
            self.dismissHUD()
            self.callOkActionMSGDialog(message: "요청되었습니다") {
              self.backPress()
            }
          })
          
        }, onError: { error in
          self.dismissHUD()
          self.callMSGDialog(message: "오류가 발생하였습니다")
        })
        .disposed(by: disposeBag)
    }
  }
  
  func uploadIamgeList(usedId: Int, success: @escaping () -> Void) {
    if uploadImages.isEmpty {
      success()
    } else {
      APIProvider.shared.usedAPI.rx.request(.imageRegister(usedId: usedId, imageList: uploadImages.map({ $0 })))
        .filterSuccessfulStatusCodes()
        .subscribe(onSuccess: { response in
          success()
        }, onError: { error in
          success()
        })
        .disposed(by: disposeBag)
    }
  }
  
  func bindInput() {
    contentTextView.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        self?.contentTextViewPlaceHolder.isHidden = !text.isEmpty
      })
      .disposed(by: disposeBag)
    
    setHashTagButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = HashtagListVC.viewController()
        vc.delegate = self
        vc.selectHashtag = self.hashtag
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    registButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
          if self.updateDetail == nil{
              self.registFood()
          }else{
              
          }
      })
      .disposed(by: disposeBag)
  }
  
}

extension RegistUsedVC: HashtagListVCDelegate {
  func setHashtag(selectHashtag: [String]) {
    hashtag = selectHashtag
    hashtagTextView.text = hashtag.map({ "#\($0)" }).joined(separator: " ")
    hashtagTextViewPlaceHolder.isHidden = true
  }
}
extension RegistUsedVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else {
                    return true
                }
                
                text = text.replacingOccurrences(of: ",", with: "")
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                
                if (string.isEmpty) {
                    // delete
                    if text.count > 1 {
                        guard let price = Int.init("\(text.prefix(text.count - 1))") else {
                            return true
                        }
                        guard let result = numberFormatter.string(from: NSNumber(value:price)) else {
                            return true
                        }
                        
                        textField.text = "\(result)"
                    }
                    else {
                        textField.text = ""
                    }
                }
                else {
                    // add
                    guard let price = Int.init("\(text)\(string)") else {
                        return true
                    }
                    guard let result = numberFormatter.string(from: NSNumber(value:price)) else {
                        return true
                    }
                    
                    textField.text = "\(result)"
                }
                
                return false
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
