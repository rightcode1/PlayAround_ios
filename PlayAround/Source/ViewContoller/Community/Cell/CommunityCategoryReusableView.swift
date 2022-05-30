//
//  CommunityCategoryReusableView.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/27.
//

import UIKit

protocol CommunityCategoryReusableViewDelegate {
  func setCategory(category: CommunityCategory)
}

class CommunityCategoryReusableView: UICollectionReusableView {
  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      collectionView.dataSource = self
      collectionView.delegate = self
      collectionView.register(UINib(nibName: "CollectionViewImageCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewImageCell")
      
      let layout = UICollectionViewFlowLayout()
      layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
      layout.itemSize = CGSize(width: 40, height: 57)
      layout.minimumInteritemSpacing = 12
      layout.minimumLineSpacing = 12
      layout.scrollDirection = .horizontal
      layout.invalidateLayout()
      collectionView.collectionViewLayout = layout
    }
  }
  
  var delegate: CommunityCategoryReusableViewDelegate?
  let categoryList: [CommunityCategory] = [.전체, .아파트별모임, .스터디그룹, .동호회, .맘카페, .기타]
  var selectedCategory: CommunityCategory = .전체
}

extension CommunityCategoryReusableView: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return categoryList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewImageCell", for: indexPath) as! CollectionViewImageCell
    let dict = categoryList[indexPath.row]
    
    cell.imageView.image = selectedCategory == dict ? dict.onImage() : dict.offImage()
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let dict = categoryList[indexPath.row]
    delegate?.setCategory(category: dict)
  }
}

