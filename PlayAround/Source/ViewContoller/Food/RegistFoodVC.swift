//
//  RegistFoodVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/13.
//

import UIKit
import RxSwift
import Photos
import DKImagePickerController

class RegistFoodVC: BaseViewController, ViewControllerFromStoryboard {
  
  @IBOutlet weak var categoryCollectionView: UICollectionView! {
    didSet {
      setCategoryCollectionView()
    }
  }
  @IBOutlet weak var statusSegmentedControl: UISegmentedControl!
  
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var priceTextField: UITextField!
  
  @IBOutlet weak var contentTextView: UITextView!
  @IBOutlet weak var contentTextViewPlaceHolder: UILabel!
  
  @IBOutlet weak var setDateAndCountView: UIView!
  @IBOutlet weak var selectDateView: UIView!
  @IBOutlet weak var dateTextField: UITextField!
  
  @IBOutlet weak var minusCountButton: UIImageView!
  @IBOutlet weak var peopleCountLabel: UILabel!
  @IBOutlet weak var plusCountButton: UIImageView!
  
  @IBOutlet weak var setHashTagButton: UIView!
  @IBOutlet weak var hashtagTextView: UITextView!
  @IBOutlet weak var hashtagTextViewPlaceHolder: UILabel!
  
  @IBOutlet weak var allergyCollectionView: UICollectionView!
  @IBOutlet weak var allergyCollectionVIewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var uploadImageCollectionView: UICollectionView!
  
  @IBOutlet weak var registButton: UIButton!
  
  var foodId: Int?
  
  let status = BehaviorSubject<FoodStatus>(value: .조리완료)
  let statusOrangeColor = UIColor(red: 255/255, green: 165/255, blue: 31/255, alpha: 1.0)
  let statusGrayColor = UIColor(red: 188/255, green: 188/255, blue: 188/255, alpha: 1.0)
  
  let segmentBackgroundImage = UIImage()
  
  let categoryList: [FoodCategory] = [.국물, .찜, .볶음, .나물, .베이커리, .저장]
  var selectedCategory: FoodCategory?
  
  var dueDate: String?
  
  var peopleCount: Int = 1
  var hashtag: [String] = []
  
  let allergyList: [FoodAllergy] = [.없음, .갑각류, .생선, .메밀복숭아, .견과류, .달걀, .우유]
  var selectedAllergyList: [FoodAllergy] = []
  
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
      if foodId != nil{
          initFoodDetail()
          setStatusSegmentedControl()
      }else{
          setStatusSegmentedControl()
      }
    bindInput()
    bindOutput()
    setCollectionViews()
  }
  
  static func viewController() -> RegistFoodVC {
    let viewController = RegistFoodVC.viewController(storyBoardName: "Food")
    return viewController
  }
  
  func setSegementBorder(index: Int) {
    if index == 0 {
      statusSegmentedControl.subviews[0].layer.borderColor = statusOrangeColor.cgColor
      statusSegmentedControl.subviews[1].layer.borderColor = statusGrayColor.cgColor
    } else {
      statusSegmentedControl.subviews[1].layer.borderColor = statusOrangeColor.cgColor
      statusSegmentedControl.subviews[0].layer.borderColor = statusGrayColor.cgColor
    }
  }
    func initFoodDetail() {
      self.showHUD()
        APIProvider.shared.foodAPI.rx.request(.foodDetail(id: self.foodId ?? 0))
        .filterSuccessfulStatusCodes()
        .map(FoodDetailResponse.self)
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
            self.titleTextField.text = data.name
            self.priceTextField.text = data.price.formattedProductPrice()
            self.contentTextView.text = data.content
            self.hashtag = data.hashtag
            self.hashtagTextView.text = self.hashtag.map({ "#\($0)" }).joined(separator: " ")
            self.hashtagTextViewPlaceHolder.isHidden = true
            self.selectedAllergyList = data.allergy
            self.allergyCollectionView.reloadData()
            self.statusSegmentedControl.selectedSegmentIndex = data.status == .조리완료 ? 0 : 1
            self.status.onNext(data.status)
            self.dueDate = data.dueDate
            self.dateTextField.text = data.dueDate
            self.peopleCountLabel.text = "\(data.userCount)"
            self.peopleCount = data.userCount ?? 0
            self.selectedCategory = data.category
            self.categoryCollectionView.reloadData()
            self.registButton.setTitle("수정하기", for: .normal)
          self.dismissHUD()
        }, onError: { error in
          self.dismissHUD()
        })
        .disposed(by: disposeBag)
    }
  
  func setStatusSegmentedControl() {
    setSegementBorder(index: 0)
//
//    statusSegmentedControl.setBackgroundImage(segmentBackgroundImage, for: .normal, barMetrics: .default)
    statusSegmentedControl.setBackgroundImage(segmentBackgroundImage, for: .selected, barMetrics: .default)
    statusSegmentedControl.setBackgroundImage(segmentBackgroundImage, for: .highlighted, barMetrics: .default)
//
    statusSegmentedControl.setDividerImage(segmentBackgroundImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    statusSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: statusGrayColor], for: .normal)
    statusSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: statusOrangeColor, .font: UIFont.systemFont(ofSize: 14, weight: .regular)], for: .selected)
  }
  
  func setCollectionViews() {
    setCategoryCollectionView()
    setAllergyCollectionViewLayout()
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
  
  func setAllergyCollectionViewLayout() {
    allergyCollectionView.dataSource = self
    allergyCollectionView.delegate = self
      
      priceTextField.delegate = self
    
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    let width = (APP_WIDTH() - 30) / 7
    layout.itemSize = CGSize(width: width, height: width + 5.5)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.invalidateLayout()
    allergyCollectionView.collectionViewLayout = layout
    allergyCollectionVIewHeightConstraint.constant = width + 5.5
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
  
  func initPeopleCountLabel() {
    peopleCountLabel.text = "\(peopleCount)"
  }
  
  func minusPeopleCount() {
    if peopleCount > 1 {
      peopleCount -= 1
    }
    initPeopleCountLabel()
  }
  
  func plusPeopleCount() {
    peopleCount += 1
    initPeopleCountLabel()
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
  
  func registFood() {
    guard let selectedCategory = selectedCategory else {
      showToast(message: "카테고리를 선택해주세요.")
      return
    }
    
    guard !titleTextField.text!.isEmpty else {
      showToast(message: "제목을 입력해주세요.")
      return
    }
    
//    guard !priceTextField.text!.isEmpty else {
//      showToast(message: "가격을 입력해주세요.")
//      return
//    }
    
    guard !contentTextView.text!.isEmpty else {
      showToast(message: "내용을 입력해주세요.")
      return
    }
    
    if try! status.value() == .조리예정 {
      if dueDate == nil {
        showToast(message: "날짜를 선택해주세요.")
        return
      }
    }
    
    if selectedAllergyList.count <= 0 {
      showToast(message: "알레르기 성분을 선택해주세요.")
      return
    }
    
    let param = FoodRegistRequest(
      category: selectedCategory,
      name: titleTextField.text!,
      content: contentTextView.text!,
      price: Int(priceTextField.text?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0,
      hashtag: hashtag,
      allergy: selectedAllergyList,
      villageId: DataHelperTool.villageId ?? 0,
      userCount: try! status.value() == .조리예정 ? peopleCount : nil,
      dueDate: dueDate,
      status: try! status.value()
    )
    
    showHUD()
    
    if let foodId = self.foodId { // 수정
      APIProvider.shared.foodAPI.rx.request(.update(id: foodId, param: param))
        .filterSuccessfulStatusCodes()
        .subscribe(onSuccess: { response in
          self.uploadIamgeList(foodId: foodId, success: {
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
      APIProvider.shared.foodAPI.rx.request(.register(param: param))
        .filterSuccessfulStatusCodes()
        .map(DefaultIDResponse.self)
        .subscribe(onSuccess: { response in
          let foodId = response.data?.id ?? 0
          self.uploadIamgeList(foodId: foodId, success: {
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
  
  func uploadIamgeList(foodId: Int, success: @escaping () -> Void) {
    if uploadImages.isEmpty {
      success()
    } else {
      APIProvider.shared.foodAPI.rx.request(.imageRegister(foodId: foodId, imageList: uploadImages.map({ $0 })))
        .filterSuccessfulStatusCodes()
        .subscribe(onSuccess: { response in
          success()
        }, onError: { error in
          success()
        })
        .disposed(by: disposeBag)
    }
  }
  
  @IBAction func segmentedControlValueChanged(_ sender: Any) {
    let selectedIndex = statusSegmentedControl.selectedSegmentIndex
//    setSegementBorder(index: selectedIndex)
    status.onNext(selectedIndex == 0 ? .조리완료 : .조리예정)
  }
  
  func bindInput() {
    contentTextView.rx.text.orEmpty
      .bind(onNext: { [weak self] text in
        self?.contentTextViewPlaceHolder.isHidden = !text.isEmpty
      })
      .disposed(by: disposeBag)
    
    selectDateView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        let vc = SelectFoodDateVC.viewController()
        vc.delegate = self
        self.present(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    minusCountButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.minusPeopleCount()
      })
      .disposed(by: disposeBag)
    
    plusCountButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.plusPeopleCount()
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
        self.registFood()
      })
      .disposed(by: disposeBag)
  }
  
  func bindOutput() {
    status
      .bind(onNext: { [weak self] status in
        guard let self = self else { return }
        self.setDateAndCountView.isHidden = status == .조리완료
      })
      .disposed(by: disposeBag)
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
  
  @objc
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
  
}

extension RegistFoodVC: SelectedDateDelegate {
  func setDate(date: String, isStart: Bool) {
    dueDate = date
    dateTextField.text = date
  }
}

extension RegistFoodVC: HashtagListVCDelegate {
  func setHashtag(selectHashtag: [String]) {
    hashtag = selectHashtag
    hashtagTextView.text = hashtag.map({ "#\($0)" }).joined(separator: " ")
    hashtagTextViewPlaceHolder.isHidden = true
  }
}

extension RegistFoodVC: UICollectionViewDelegate, UICollectionViewDataSource {
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
    } else if allergyCollectionView == collectionView {
      return allergyList.count
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
    } else if allergyCollectionView == collectionView {
      let cell = allergyCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      guard let imageView = cell.viewWithTag(1) as? UIImageView else { return cell }
      let dict = allergyList[indexPath.row]
      
      imageView.image = selectedAllergyList.contains(dict)  ? dict.onRegistImage() : dict.offRegistImage()
      
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
    } else if allergyCollectionView == collectionView {
      let dict = allergyList[indexPath.row]
      if selectedAllergyList.contains(dict) {
        selectedAllergyList.remove(dict)
      } else {
        selectedAllergyList.append(dict)
      }
      
      allergyCollectionView.reloadData()
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

extension RegistFoodVC: UITextFieldDelegate{
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
// MARK: - DKImagePickerControllerBaseUIDelegate

class AssetClickHandler: DKImagePickerControllerBaseUIDelegate {
  override func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset]) {
    //tap to select asset
    //use this place for asset selection customisation
    print("didClickAsset for selection")
  }
  
  override func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
    //tap to deselect asset
    //use this place for asset deselection customisation
    print("didClickAsset for deselection")
  }
}
