//
//  VoteCell.swift
//  PlayAround
//
//  Created by 이남기 on 2023/01/05.
//

import Foundation
import UIKit
import SwiftUI
import RxSwift
import RxCocoa
import RxGesture

protocol voteProtocol{
    func add(index: Int)
    func delete(index: Int)
    func contentSave(index: Int,content:String)
}

class VoteCell:UITableViewCell{
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    var indexPath :Int = -1
    var data: Choices?
    var delegate: voteProtocol?
    var disposeBag = DisposeBag()
    
    func initVote(dict: Choices){
        data = dict
        if data?.status ??  false{
            button.setTitle("추가", for: .normal)
        }else{
            button.setTitle("삭제", for: .normal)
        }
        contentTextField.rx.controlEvent(.editingDidEnd)
          .bind(onNext: { [weak self] in
            guard let self = self else { return }
              self.delegate?.contentSave(index: self.indexPath, content: self.contentTextField.text ?? "")
          })
          .disposed(by: disposeBag)
    }
    
    @IBAction func tapAddorDelete(_ sender: Any) {
        if data?.status ??  false{
            delegate?.delete(index: indexPath)
        }else{
            delegate?.add(index: indexPath)
        }
    }
}
