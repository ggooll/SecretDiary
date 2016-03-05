//
//  MainViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 11..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit
import CVCalendar
import SWRevealViewController


// 앱이 실행되고 비밀번호를 해제할 경우 오는 메인뷰
class MainViewController: UIViewController, UITextViewDelegate {


    // IBOutlet
    @IBOutlet weak var MainBackGroundImage: UIImageView!
    @IBOutlet weak var TodayButton: UIButton!
    @IBOutlet weak var ItemButton: UIButton!
    @IBOutlet weak var MainSubject: UITextView!
    @IBOutlet weak var MainContent: UITextView!
    @IBOutlet weak var ModifyBtn: UIButton!
    @IBOutlet weak var SubjectLine: UIView!
    @IBOutlet weak var TodayLabel: UILabel!
    
    var LoginAuth:IdentificationInfo!
    var TodayInfo:WriteDiaryInfo!
    let groundImage:[String!] = ["background0", "background1", "background2", "background3", "background4", "background5", "background6", "background7", "background8", "background9",]
    var DateArray: [String]!
    
    
    func initView(){
        // 이미지를 랜덤으로 번갈아가면서 바꿔줌 + 백그라운드 이미지 Blur효과
        let randomNumber : Int = Int(rand()) % 9
        let image = UIImage(named: groundImage[randomNumber])
        MainBackGroundImage.image = image
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.MainBackGroundImage.addSubview(blurEffectView)
        
        // 날짜는 한글자 - 1월 2일의경우  - 01월 02일과같이 바꿔줌 - 디비와의 통신에 용이함을 위하여
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
        // 오늘의 정보를 가지고 있도록 함 - Write시 가지고 들어감
        TodayInfo = WriteDiaryInfo(year: String(CVDate(date: NSDate()).year), month: monthString, day: dayString)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // 이전에 앱이 계속 켜져있다면 메인에서 비밀번호 검사를 하지 말아야함
        if self.LoginAuth == nil{
            LoginAuth = IdentificationInfo()
        }
        
        //password view를 띄움 - 처음들어왔다면 무조건 0이므로 모달이 실행됨
        if LoginAuth.getLoginFlag() != 1{
            self.performSegueWithIdentifier("DoPassWord", sender: self)
        }

        // popup button - split view(revealViewController) 연결
        ItemButton.addTarget(self.revealViewController(), action: Selector("revealToggle:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
    }
    
    // status바를 lightContent로 함
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // 네비게이션 바를 가림 / 오늘의일기가 없다면 버튼을보이게 or 오늘의 일기가 있다면 내용을 띄워줌
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = true
        
        let dbmgr = dbMgr()
        DateArray = dbmgr.select_AllDate()
        let day = "\(TodayInfo.thisYear)\(TodayInfo.thisMonth)\(TodayInfo.thisDay)"
        
        
        // 오늘내용이 있다면 버튼을 안보이게하고 내용을 보여줘야 함
        if isExistThisDay(day) == true{
            MainContent.hidden = false
            MainSubject.hidden = false
            ModifyBtn.hidden = false
            SubjectLine.hidden = false
            TodayButton.hidden = true
            TodayLabel.hidden = false
            
            TodayLabel.text = "오늘은 \(TodayInfo.thisYear)년 \(TodayInfo.thisMonth)월 \(TodayInfo.thisDay)일입니다."
            let TodayObject = dbmgr.select_SelectedDay(day)
            MainSubject.text = TodayObject?.Subject
            
            if let mutacontent = NSKeyedUnarchiver.unarchiveObjectWithData(TodayObject!.Content){
                let MutString = mutacontent as! NSMutableAttributedString
                
                // NSMutuableAttributedString내의 다양한 속성들을 순차적으로 돌며 검사시켜줌 
                // 여기서 이미지를 만나면 이미지의 크기 및 속성을바꿔서 다시뿌려줘야함... 해당 위치에!
                MutString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, MutString.length), options: .LongestEffectiveRangeNotRequired) { (value, range, stop) -> Void in
                    if let attachement = value as? NSTextAttachment {
                        // attachment를 찾았다면 - 이미지만고려하였으므로 이미지이다.
                        // 이미지 속성을가져와 새로 바꾸고 다시 붙여줌
                        let image = attachement.imageForBounds(attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location+1)
                        let newAttribut = NSTextAttachment()
                        newAttribut.image = UIImage(data: image!.lowestQualityJPEGNSData)
                        newAttribut.bounds = CGRectMake(0.0, 0.0, self.view.bounds.width-25, self.view.bounds.width-25)
                        
                        // NSMutablAttributedString 에만 적용됨
                        MutString.addAttribute(NSAttachmentAttributeName, value: newAttribut, range: range)
                        //let carrage = NSAttributedString(string: "\n")
                        //MutString.insertAttributedString(carrage, atIndex: range.location)
                    }
                }
                MainContent.attributedText = MutString
                MainContent.textStorage.addAttributes(MainContent.typingAttributes, range: MainContent.selectedRange)
                
            }
            else{
                MainContent.text = "LOAD FAIL"
            }
            MainContent.textColor = UIColor.groupTableViewBackgroundColor()
        }
        // 내용이 없다면 버튼을 보이게 함!
        else{
            MainContent.text = nil
            MainSubject.text = nil
            TodayLabel.text = nil
            MainContent.hidden = true
            MainSubject.hidden = true
            ModifyBtn.hidden = true
            SubjectLine.hidden = true
            TodayLabel.hidden = false
            TodayButton.hidden = false
        }
        

        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // WriteViewController로 들어갈때 오늘의 날짜를 가지고 들어갑니다.
        if(segue.identifier == "MainToWriteDiary"){
            let destinationController = segue.destinationViewController as! WriteViewController
            destinationController.SelectedDay = "\(TodayInfo.thisYear)\(TodayInfo.thisMonth)\(TodayInfo.thisDay)"
        }
        
        //로그인했다는 정보를 가지고 돌아다니기 위해서..
        if(segue.identifier == "DoPassWord"){
            let destinationController = segue.destinationViewController as! PassSignViewController
            destinationController.LoginAuth = self.LoginAuth
            print(LoginAuth)
        }
        
        // SWRevealViewController를 위해 필요함 (Tab은 해당 API를 이용하여 Custom segur로 연결되어있음)
        if(segue.identifier == "sw_rear"){
            let destinationController = segue.destinationViewController as! TabPopUpTableViewController
            destinationController.LoginAuth = self.LoginAuth
        }
    }
    
   // 오른쪽위의 수정버튼을 누르면 Write뷰가 모달로 생성
    @IBAction func pressModifyBtn(sender: UIButton){
        performSegueWithIdentifier("MainToWriteDiary", sender: nil)
        
    }
    
    // Unwind segue - write모달이 닫힘
    @IBAction func WriteToBack(segue:UIStoryboardSegue) {
    }
    
    // Unwind segue - passsignview 모달이 닫힘
    @IBAction func PassWordToMain(segue:UIStoryboardSegue) {
    }

    
    func isExistThisDay(checkday: String)->Bool{
        
        for thisday in DateArray{
            if thisday == checkday{
                return true
            }
        }
        return false
    }
    
    
}


extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}


