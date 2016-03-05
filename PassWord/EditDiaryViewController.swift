//
//  EditDiaryViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 14..
//  Copyright © 2015년 규철 임. All rights reserved.
//


import UIKit
import CVCalendar
import Foundation
//import CoreLocation


class EditDiaryViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    // IBOutlet
    @IBOutlet weak var ContentText: UITextView!
    @IBOutlet weak var SubjectText: UITextView!
    @IBOutlet weak var WeatherBtn: UIButton!
    @IBOutlet weak var FaceBtn: UIButton!
    
    var SelectedDayInfo:WriteDiaryInfo!
    var dbmgr:dbMgr!
    var SaveObject:DiaryObject!
    var LoadObject:DiaryObject!
    var SelectedDay:String!
    var UpdateFlag:Bool!
    var WeatherFlag:Int! = 0
    var FaceFlag:Int! = 0
    var imageArray = NSMutableArray()
    
    let WeatherImage:[String]! = ["weather_sunny","weather_windy","weather_rainy","weather_cloudy","weather_snow"]
    let FaceImage:[String]! = ["feel_normal","feel_smile","feel_bad","feel_cry","feel_angry"]
    //let PaperImage:[String]! = ["paper1","paper2","paper3","paper4"]
    
    
    
    // 오늘의 날짜와 비교하여 더 앞의 날짜로의 작성동작은 되지 않도록 해야함
    // 기존의 일기를 보여주고 에디팅이 가능하게 하는경우 / 오늘의 경우는 바로 에디팅이 가능하게끔 해줌
    override func viewDidLoad() {
        super.viewDidLoad()
        dbmgr = dbMgr()
        SelectedDay = "\(SelectedDayInfo.thisYear)\(SelectedDayInfo.thisMonth)\(SelectedDayInfo.thisDay)"
        initPaperView()
        initTextView()
        
        // 다이어리가 존재한다면 해당 다이어리 가 LoadObject가 됨 - optional binding
        if let isDiary = dbmgr.select_SelectedDay(SelectedDay){
            LoadObject = isDiary
            UpdateFlag = true
            initLoadView()
        }
        else{
            // 해당 다이어리가 존재하지 않으면 Write를 바로 모달로 띄움
            UpdateFlag = false
            LoadObject = DiaryObject()
            self.performSegueWithIdentifier("EditToWrite", sender: nil)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.navigationItem.title = "\(SelectedDayInfo.thisYear)년 \(SelectedDayInfo.thisMonth)월 \(SelectedDayInfo.thisDay)일"
        dbmgr = dbMgr()
        
        if let temp = dbmgr.select_SelectedDay(SelectedDay){
            LoadObject = temp
            UpdateFlag = true
        }else{
            LoadObject = DiaryObject()
            UpdateFlag = false
        }
        initLoadView()
    }

    
    
    // BackgroundView initial
    func initPaperView(){
        UIGraphicsBeginImageContext(self.view.frame.size);
        //var image = UIImage(named: "yellownote")!
        var image = UIImage(named: "paper")!
        
        image.drawInRect(self.view.frame)
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    
    
    // Load Diary - MainView의 Content TextView와 방식이 같음 
    // 받아온 NSData를 NSAttributeString으로 변경하여 내부 attachment들을 다시 재정비하는 식으로 뷰를 꾸림 
    // 이미지를 디비에 저장했다가 다시 불러오면 설정했던 bound를 무시하고 원래크기로 뿌려주기때문에 반드시 필요... 
    func initLoadView() -> Bool{
        SubjectText.text = LoadObject.Subject
        if let mutacontent = NSKeyedUnarchiver.unarchiveObjectWithData(LoadObject.Content){
            let MutString = mutacontent as! NSMutableAttributedString
            
            MutString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, MutString.length), options: .LongestEffectiveRangeNotRequired) { (value, range, stop) -> Void in
                if let attachement = value as? NSTextAttachment {
                    
                    //print(range)
                    let image = attachement.imageForBounds(attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location+1)
                    
                    let newAttribut = NSTextAttachment()
                   
                    //newAttribut.image = image!
                    newAttribut.image = UIImage(data: image!.lowestQualityJPEGNSData)
                    newAttribut.bounds = CGRectMake(0.0, 0.0, self.view.bounds.width-20, self.view.bounds.width-20)
                    
                    // NSMutablAttributedString 에만 적용됨
                    MutString.addAttribute(NSAttachmentAttributeName, value: newAttribut, range: range)
                    //let carrage = NSAttributedString(string: "\n")
                    //MutString.insertAttributedString(carrage, atIndex: range.location)
                }
            }
            ContentText.attributedText = MutString
            ContentText.textStorage.addAttributes(ContentText.typingAttributes, range: ContentText.selectedRange)
            
        }
        else{
            ContentText.text = "LOAD FAIL"
        }
        
        
        WeatherBtn.setImage(UIImage(named:WeatherImage[LoadObject.Weather]), forState: .Normal)
        WeatherFlag = LoadObject.Weather
        FaceBtn.setImage(UIImage(named:FaceImage[LoadObject.Face]), forState: .Normal)
        FaceFlag = LoadObject.Face
        return true
    }
    
    // TextView initial - 패딩, 인셋, 배경칼라, 최대라인수등을 초기화함
    func initTextView(target: UITextView, line: Int){
        target.delegate = self
        target.editable = false
        target.textContainer.maximumNumberOfLines = line
        target.textContainer.lineFragmentPadding = 0
        target.textContainerInset = UIEdgeInsetsZero
        target.layer.borderWidth = 0.5
        target.layer.borderColor = UIColor.clearColor().CGColor
        target.backgroundColor = UIColor.clearColor()
        target.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        target.clipsToBounds = true
    }

    func initTextView(){
        initTextView(ContentText, line: 0)
        initTextView(SubjectText, line: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "EditToWrite"{
            let destinationController = segue.destinationViewController as! WriteViewController
            destinationController.SelectedDay = self.SelectedDay
            destinationController.UpdateFlag = self.UpdateFlag
        }
    }
    
    

    /////////////// @IBAction Btn ActionListener   //////////////////////
    
    // 일기 삭제(휴지통 버튼) 
    // 일기를 삭제한 후에 EditDiary로 올수있는 MyDiary와 Calendar중 네비게이션컨트롤러의 뷰스택들을 검사하며 해당 컨트롤러인경우 그곳으로 unwind합니다.
    @IBAction func DeleteBtn(sender: AnyObject){
        let alert = UIAlertController(title: "", message: "일기를 삭제하시겠습니까?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default,
            handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler:
            {action in
                if self.dbmgr.delete(self.SelectedDay) == true{
                    let VCArray = self.navigationController?.viewControllers
                    for vc in VCArray!{
                        if vc.isKindOfClass(CalendarMainViewController){
                            self.performSegueWithIdentifier("WriteToCalendar", sender: self)
                        }
                        else if vc.isKindOfClass(MyDiaryTableTableViewController){
                            self.performSegueWithIdentifier("WriteToMyDiary", sender: self)
                        }
                    }
                }
        }))
        self.presentViewController(alert, animated: false, completion: nil)
        
    }

    // unwind segue
    @IBAction func WriteToBack(segue:UIStoryboardSegue) {
    }
    
}
