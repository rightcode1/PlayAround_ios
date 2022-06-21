//
//  FoodCategoryReusableView.swift
//  PlayAround
//
//  Created by haon on 2022/05/23.
//

import UIKit

protocol FoodCategoryReusableViewDelegate {
  func setCategory(category: FoodCategory)
}

class FoodCategoryReusableView: UICollectionReusableView {
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
  
  var delegate: FoodCategoryReusableViewDelegate?
  
  let categoryList: [FoodCategory] = [.전체, .국물, .찜, .볶음, .나물, .베이커리, .저장]
  var selectedCategory: FoodCategory = .전체
}

extension FoodCategoryReusableView: UICollectionViewDelegate, UICollectionViewDataSource {
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

