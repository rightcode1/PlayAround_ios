//
//  SelectFoodDateVC.swift
//  PlayAround
//
//  Created by haon on 2022/06/14.
//

import UIKit
import FSCalendar

class SelectFoodDateVC: BaseViewController, ViewControllerFromStoryboard {
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
  
  static func viewController() -> SelectFoodDateVC {
    let viewController = SelectFoodDateVC.viewController(storyBoardName: "Food")
    return viewController
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
  
}
extension SelectFoodDateVC: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    calendar.select(date.noon)
    selectedDate = date.noon.toString(dateFormat: "yyyy-MM-dd")
    
    backPress()
    delegate?.setDate(date: selectedDate!, isStart: isStart ?? false)
  }
}
