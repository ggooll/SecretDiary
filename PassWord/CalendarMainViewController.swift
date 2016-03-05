//
//  CalendarMainViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 8..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit
import CVCalendar


// CalendarViewController - CVCalendar API 이용
class CalendarMainViewController: UIViewController, UIPopoverPresentationControllerDelegate, CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate  {
    
    @IBOutlet weak var PopBtn: UIBarButtonItem!
    @IBOutlet weak var WriteBtn: UIBarButtonItem!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var monthLabel: UILabel!
    
    var shouldShowDaysOut = true
    var animationFinished = true
    var PassDateInfo: WriteDiaryInfo!
    var DateArray: [String]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 레이블에 현재의 년/달 표시
        monthLabel.text = CVDate(date: NSDate()).globalDescription
        menuView.backgroundColor = UIColor.clearColor()
        calendarView.backgroundColor = UIColor.clearColor()
        
        initDayInfo()
        initBtnInfo()
        
        // 탭뷰버튼 연결
        PopBtn.target = revealViewController()
        PopBtn.action = ("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // 날짜를 가지고있게 하기 위함 - 작성할 경우 dateInfo를 가져야 함
    // 선택되지않은경우 - 들어가자마자 바로 작성버튼을누르면 오늘의 날짜정보를 가지고있지않음 (액션에 의해 얻어오기때문에)
    func initDayInfo(){
        let zeroString = "0"
        var monthString:String! = ""
        var dayString:String! = ""
        
        if CVDate(date: NSDate()).month < 10 {
            monthString = zeroString + String(CVDate(date: NSDate()).month)
        } else {
            monthString = String(CVDate(date: NSDate()).month)
        }
    
        if CVDate(date: NSDate()).day < 10 {
            dayString = zeroString + String(CVDate(date: NSDate()).day)
        } else {
            dayString = String(CVDate(date: NSDate()).day)
        }
        PassDateInfo = WriteDiaryInfo(year: String(CVDate(date: NSDate()).year), month: monthString, day: dayString)
    }
    
    
    // 오늘날짜로 돌아오는 버튼과 popover spinner를 여는 버튼 설정
    func initBtnInfo(){
        todayBtn.layer.cornerRadius = 0.5 * todayBtn.layer.bounds.size.width
        todayBtn.layer.masksToBounds = true
        todayBtn.layer.borderWidth = 1.5
        todayBtn.layer.borderColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0).CGColor
        
        searchBtn.layer.cornerRadius = 0.5 * todayBtn.layer.bounds.size.width
        searchBtn.layer.masksToBounds = true
        searchBtn.layer.borderWidth = 1.5
        searchBtn.layer.borderColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0).CGColor
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    
    // 세규를 연결합니다. 캘린더의경우 작성창, 뷰창으로 둘다 넘어갈 수 있는 유일한 네비게이터임
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "CalendarToDiaryView"{
            let destinationController = segue.destinationViewController as! EditDiaryViewController
            destinationController.SelectedDayInfo = self.PassDateInfo
        }
        
        if segue.identifier == "CalendarToEdit"{
            let destinationContoller = segue.destinationViewController as! WriteViewController
            destinationContoller.SelectedDay = "\(PassDateInfo.thisYear)\(PassDateInfo.thisMonth)\(PassDateInfo.thisDay)"
        }
    }
    
    
}





// 캘린더API의 여러속성을 이용하기위한 extension 정의
extension CalendarMainViewController {
    
    // WeekView도 존재하지만 사용하지 않기로 결정
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    // 일월화수목금토 의 순서로 보이게 함
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    // 달력 크기 커질때
    func shouldAnimateResizing() -> Bool {
        return true
    }
    
    // 날짜 선택됬을때... 프린트
    func didSelectDayView(dayView: DayView) {
        let zeroString = "0"
        var monthString:String! = ""
        var dayString:String! = ""
        
        if dayView.date.month < 10 {
            monthString = zeroString + String(dayView.date.month)
        } else {
            monthString = String(dayView.date.month)
        }
        
        if dayView.date.day < 10 {
            dayString = zeroString + String(dayView.date.day)
        } else {
            dayString = String(dayView.date.day)
        }
        PassDateInfo = WriteDiaryInfo(year: String(dayView.date.year), month: monthString, day: dayString)
        
    }
    
    
    // 날짜가 선택, 혹은 달을 넘김으로서 포커싱되야하는 경우의 애니메이션들을 정의
    func presentedDateUpdated(date: CVDate) {
        if monthLabel.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { _ in
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.text = updatedMonthLabel.text
                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    

    // 날짜가 선택된 경우 날짜 글씨 주변을 포커싱해주는 메소드
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    
    // 일기가 저장된 날짜에만 dot을 찍어주기 위해 사용
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        if DateArray == nil{
            let dbmgr = dbMgr()
            DateArray = dbmgr.select_AllDate()
        }
        
        var day = String(dayView.date.day)
        var month = String(dayView.date.month)
        let year = String(dayView.date.year)
        let zeroString = "0"
        
        if Int(month) < 10 {  month = zeroString + month}
        if Int(day) < 10 { day = zeroString + day }
        
        let dayString = year + month + day
        return isExistThisDay(dayString)
    }
    
    
    // 해당 날짜에 메모가 기입되어 있는가?
    func isExistThisDay(checkday: String)->Bool{
        for thisday in DateArray{
            if thisday == checkday{
                return true
            }
        }
        return false
    }
    
    
    // dot의 색상을 변경하기 위한 메소드
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        // RGB값 생성하여 array로 넘김
        // 여러가지 색상을 생성하여 array로 넘기면 랜덤으로 사용함
        let color = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
        return [color]
    }
    
    // dot이 있는곳이 선택됬을때 highlight시킬지의 여부
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    // 날짜아래의 dot의 크기
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 13
    }
    
    // Monday Tuesday와 같은 심볼을 여러가지 형태로 제공해줌 
    // .normal(MONDAY, TUESDAY..), short(MON, TUE..), ultrashort(M,T,W..)
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }
    
    
    // 오늘의 날짜를 띄워주는 메소드 이용
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
    
    // 작성을 누르면 이미 일기가있는경우 View로, 없는경우 Write모달을 띄움
    @IBAction func PressEditbtn(sender:AnyObject!){
        //let dbmgr2 = dbMgr()
        let diary = "\(PassDateInfo.thisYear)\(PassDateInfo.thisMonth)\(PassDateInfo.thisDay)"
        
        
        if isExistThisDay(diary){
            performSegueWithIdentifier("CalendarToDiaryView", sender: nil)
        }
        else{
            performSegueWithIdentifier("CalendarToEdit", sender: nil)
        }
     
    }
    
    
    // unwind segue들
    @IBAction func WriteToCalendar(segue:UIStoryboardSegue) {
    }
    
    @IBAction func WriteToBack(segue:UIStoryboardSegue){
        
    }
    
    
    // 날짜를 선택하는 datepicker를 popover형태로 띄우기 위함
    @IBAction func PressSearchBtn(sender:AnyObject!){
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: "handleDatePicker:", forControlEvents:UIControlEvents.AllEvents)
        
        let vc = UIViewController()
        vc.view.addSubview(datePicker)
        vc.modalPresentationStyle = .Popover
        vc.preferredContentSize = datePicker.frame.size
        
        if let ppc = vc.popoverPresentationController{
            ppc.delegate = self
            //ppc.sourceRect = self.searchBtn.frame
            ppc.sourceRect = CGRectMake(30, 550, 0,0)
            ppc.sourceView = vc.view
            ppc.permittedArrowDirections = UIPopoverArrowDirection.Any
        }
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    // popover를 위해 꼭 필요함 
    // 2.0의 팝오버는 기존과 다른방식으로 변경됨 popoverPresentationConroller로 생성됨
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // datepicker를
    func handleDatePicker(sender: UIDatePicker){
        calendarView.toggleViewWithDate(sender.date)
    }
    
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    // dayView간의 간격 2.0
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
    
    
}




