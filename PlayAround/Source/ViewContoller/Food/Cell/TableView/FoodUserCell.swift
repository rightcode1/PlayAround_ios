//
//  FoodUserCell.swift
//  PlayAround
//
//  Created by 이남기 on 2022/12/29.
//

import UIKit
import RxSwift

protocol FoodUserCellDelegate {
    func chat(userId: Int)
    func delete(userId: Int,index: Int)
}

class FoodUserCell: UITableViewCell {
    
    @IBOutlet weak var userThumbnail: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    var delegate: FoodUserCellDelegate?
    var dict: User?
    var index: Int?
  
    override func awakeFromNib() {
      super.awakeFromNib()
    }
    
    func initList(data: User){
        userThumbnail.kf.setImage(with: URL(string: data.thumbnail ?? ""))
        userName.text = data.name
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        delegate?.delete(userId: dict?.id ?? 0, index: index ?? 0)
    }
    
    @IBAction func chatButton(_ sender: Any) {
        delegate?.chat(userId: dict?.id ?? 0)
    }

}
