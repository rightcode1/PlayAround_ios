//
//  UsedVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/15.
//

import UIKit

class UsedVC: BaseViewController, UsedCategoryReusableViewDelegate, SelectVillage {
    func select() {
    }
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var usedListCollectionView: UICollectionView!
    @IBOutlet weak var villageButton: UIButton!
    
    
    var category: UsedCategory = .전체
    var usedList: [UsedListData] = []
    
    var sort: FoodSort?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUsedListCollectionViewLayout()
        bindInput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        villageButton.setTitle(DataHelperTool.villageName, for: .normal)
        initUsedList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setUsedListCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        layout.itemSize = CGSize(width: (APP_WIDTH() - 40) / 2, height: 175)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.headerReferenceSize = CGSize(width: APP_WIDTH(), height: 87)
        layout.invalidateLayout()
        usedListCollectionView.collectionViewLayout = layout
    }
    
    // UsedCategoryReusableViewDelegate
    func setCategory(category: UsedCategory) {
        self.category = category
        initUsedList()
    }
    
    func initUsedList() {
        self.showHUD()
        let param = UsedListRequest(category: category == .전체 ? nil : category,villageId: DataHelperTool.villageId , sort: sort == nil ? .최신순 : sort)
        APIProvider.shared.usedAPI.rx.request(.list(param: param))
            .filterSuccessfulStatusCodes()
            .map(UsedListResponse.self)
            .subscribe(onSuccess: { value in
                self.initAdvertisementList(usedList: value.list)
            }, onError: { error in
                self.dismissHUD()
            })
            .disposed(by: disposeBag)
    }
    
    func initAdvertisementList(usedList: [UsedListData]) {
        let param = AdvertisementListRequest(location: .광고리스트, category: .중고거래)
        APIProvider.shared.advertisementAPI.rx.request(.list(param: param))
            .filterSuccessfulStatusCodes()
            .map(AdvertisementListResponse.self)
            .subscribe(onSuccess: { value in
                self.usedList = usedList
                
                if value.list.count > 0 {
                    for i in 0..<value.list.count {
                        let checkCount = ((i + 1) * 5)
                        if self.usedList.indices.contains(checkCount) && self.usedList.indices.contains(checkCount + i) {
                            let usedListData = UsedListData(id: 0, thumbnail: nil, category: .가전, name: "", price: 0, wishCount: 0, isWish: true, statusSale: false, isLike: nil, likeCount: 0, dislikeCount: 0, user: nil, address: "", villageId: 0, viewCount: 0, commentCount: 0, hashtag: [], isReport: false, advertisementData: value.list[i])
                            self.usedList.insert(usedListData, at: checkCount + i)
                        }
                    }
                }
                
                self.usedListCollectionView.reloadData()
                self.dismissHUD()
            }, onError: { error in
            })
            .disposed(by: disposeBag)
    }
    
    func bindInput() {
        filterButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                let vc = FoodSortPopupVC.viewController()
                vc.delegate = self
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                let vc = SearchFoodAndUsedVC.viewController()
                vc.selectedDiff = .used
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        villageButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "VillageListVC") as! VillageListVC
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension UsedVC: FoodSortDelegate {
    func setFoodSort(sort: FoodSort) {
        self.sort = sort
        initUsedList()
    }
}

extension UsedVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = usedListCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! UsedCategoryReusableView
            headerView.delegate = self
            headerView.selectedCategory = category
            headerView.collectionView.reloadData()
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usedList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = usedListCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FoodListCell
        let dict = usedList[indexPath.row]
        if dict.advertisementData == nil {
            cell.update(dict)
        } else {
            cell.updateWithAdvertisementData(dict.advertisementData!)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = usedList[indexPath.row]
        if dict.advertisementData == nil {
            let vc = UsedDetailVC.viewController()
            vc.usedId = dict.id
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if let advertisement = dict.advertisementData {
                if advertisement.diff == "url" {
                    if let openUrl = URL(string: advertisement.url!) {
                        UIApplication.shared.open(openUrl, options: [:])
                    }
                } else {
                    let vc = AdvertisementDetailVC.viewController()
                    vc.images = [Image(id: 0, name: advertisement.image ?? "")]
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }
    }
}
