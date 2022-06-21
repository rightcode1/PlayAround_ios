//
//  SelectedDateView.swift
//  coffitForManager
//
//  Created by hoon Kim on 2022/03/16.
//

import UIKit
import FSCalendar

protocol SelectedDateDelegate {
  func setDate(date: String, isStart: Bool)
}

class SelectedDateView: UIViewController {
  
  @IBOutlet var calendarDateLabel: UILabel!
  @IBOutlet var calendar: FSCalendar!
  
  var delegate: SelectedDateDelegate?
  var isStart: Bool!
  var selectedDate: String?

    override func viewDidLoad() {
        super.viewDidLoad()
      calendar.delegate = self
      setCalendarHeaderDate(date: Date())
      
      if selectedDate == nil {
        calendar.select(Date())
        selectedDate = Date().toString(dateFormat: "yyyy-MM-dd")
      }
    }

  func setCalendarHeaderDate(date: Date) {
    let monthDateFormatter = DateFormatter()
    monthDateFormatter.dateFormat = "yyyy년 MM월"
    calendarDateLabel.text = monthDateFormatter.string(from: date)
  }
  
  func getNextMonth(date:Date)->Date {
    return  Calendar.current.date(byAdding: .month, value: 1, to:date)!
  }
  
  func getPreviousMonth(date:Date)->Date {
    return  Calendar.current.date(byAdding: .month, value: -1, to:date)!
  }
  
  @IBAction func nextTapped(_ sender: UIButton) {
    calendar.setCurrentPage(getNextMonth(date: calendar.currentPage), animated: true)
    setCalendarHeaderDate(date: calendar.currentPage)
  }
  
  @IBAction  func previousTapped(_ sender: UIButton) {
    calendar.setCurrentPage(getPreviousMonth(date: calendar.currentPage), animated: true)
    setCalendarHeaderDate(date: calendar.currentPage)
  }
    
  @IBAction func tapBack(_ sender: UIButton) {
    backPress()
  }
  
  @IBAction func tapSave(_ sender: UIButton) {
    backPress()
    delegate?.setDate(date: selectedDate!, isStart: isStart!)
  }

}
extension SelectedDateView: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    calendar.select(date.noon)
    selectedDate = date.noon.toString(dateFormat: "yyyy-MM-dd")
  }
}
