//
//  UsedCategoryReusableView.swift
//  PlayAround
//
//  Created by haon on 2022/06/15.
//

import UIKit

protocol UsedCategoryReusableViewDelegate {
  func setCategory(category: UsedCategory)
}

class UsedCategoryReusableView: UICollectionReusableView {
  
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
  
  var delegate: UsedCategoryReusableViewDelegate?
  
  let categoryList: [UsedCategory] = [.전체, .육아, .골프, .서적, .가전, .IT, .소형가전]
  var selectedCategory: UsedCategory = .전체
}

extension UsedCategoryReusableView: UICollectionViewDelegate, UICollectionViewDataSource {
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
