//
//  CommunityVote.swift
//  PlayAround
//
//  Created by 이남기 on 2022/06/05.
//

import Foundation
import UIKit

protocol tapRegister{
    func vote(list : [Choices],endDate:String,title:String,overlap:Bool)
}
                     
struct Choices: Codable{
    var content:String
    var status:Bool? = false
}
class CommunityVoteVC: BaseViewController, voteProtocol, SelectedDateDelegate{
    func setDate(date: String, isStart: Bool) {
        selectDateTextField.text = date
        endDate = date
    }
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var selectDateView: UIView!
    @IBOutlet weak var selectDateTextField: UITextField!
    @IBOutlet weak var checkOnOff: UIImageView!
    
    var endDate: String = ""
    var endTime: String = "13:00"
    var checkBool: Bool = false
    
    var delegate: tapRegister?
    
    var tableList : [Choices] = [Choices.init(content: ""),Choices.init(content: ""),Choices.init(content: "",status: true)]{
        didSet{mainTableView.reloadData()
        }
    }
    
    func add(index: Int) {
        tableList.remove(at: index)
    }
    
    func delete(index: Int) {
        tableList[index].status = false
        tableList.append(Choices.init(content: "",status: true))
    }
    
    func contentSave(index: Int,content:String) {
        tableList[index].content = content
    }
    override func viewDidLoad() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.layoutTableHeaderView()
        bindInput()
    }
    @IBAction func tapRegister(_ sender: Any) {
        if titleTextField.text!.isEmpty{
            showToast(message: "투표 제목을 입력해주세요.")
            return
        }
        
        if tableList.count < 1{
            showToast(message: "2개 이상의 투표항목을 입력해주세요.")
            return
        }
        
        if endDate == ""{
            showToast(message: "마감 날짜를 선택해주세요.")
            return
        }
        
        if endTime == ""{
            showToast(message: "마감 시간을 선택해주세요.")
            return
        }
        delegate?.vote(list: tableList,endDate:endDate,title:titleTextField.text!,overlap:checkBool)
        backPress()
    }
    
    func bindInput() {
      
      selectDateView.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          guard let self = self else { return }
          let vc = SelectFoodDateVC.viewController()
          vc.delegate = self
          self.present(vc, animated: true)
        })
        .disposed(by: disposeBag)
        checkOnOff.rx.tapGesture().when(.recognized)
            .bind(onNext: { [weak self] _ in
              guard let self = self else { return }
                if self.checkBool{
                    self.checkOnOff.image = UIImage(named: "communityCheckOff")
                    self.checkBool = false
                }else{
                    self.checkOnOff.image = UIImage(named: "communityCheckOn")
                    self.checkBool = true
                }
            })
            .disposed(by: disposeBag)
    }
}
extension CommunityVoteVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! VoteCell
        let dict = tableList[indexPath.row]
        cell.indexPath = indexPath.row
        cell.initVote(dict: dict)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61.5
    }
    
}
