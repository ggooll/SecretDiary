//
//  SettingTableTableViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 17..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit
import Foundation
import MessageUI


// SettingTable을 위한 테이블뷰 컨트롤러입니다.
class SettingTableTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    // IBOutlet
    @IBOutlet weak var PopBtn: UIBarButtonItem!
    @IBOutlet weak var TopGround: UIImageView!
    @IBOutlet weak var BottomGround: UIImageView!
    
    var dbmgr:dbMgr!
    var jsonMgr:JSONMgr!
    
    let WeatherString:[String]! = ["맑음", "구름많음", "바람", "비옴", "눈옴"]
    let FaceString:[String]! = ["보통", "좋음", "나쁨", "슬픔", "화남"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PopBtn.target = self.revealViewController()
        PopBtn.action = ("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
       
        dbmgr = dbMgr()
        jsonMgr = JSONMgr()
        TopGround.backgroundColor = UIColor.whiteColor()
        BottomGround.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // StaticTable의 셀이 선택되었을때 (3개의 섹션으로 이루어져 있음)
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // password
        if indexPath.section == 0{
            // password modify - 비밀번호 변경 (SettingPasswordViewController가 modal로 생성됨)
            if indexPath.row == 0{
                performSegueWithIdentifier("ModifyPassWord", sender: self)
            }
            // password reset - 비밀번호 초기화 (alert와 DB수정)
            else if indexPath.row == 1{
                let alert = UIAlertController(title: "Password Reset", message: "비밀번호를 초기화하시겠습니까?", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alert, animated: false, completion: nil)
            
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default,
                    handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler:
                    {action in      
                        let dbmgr = dbMgr()
                        let TempInfo = dbmgr.getMyInfo()
                        TempInfo.setPassWord("0000")
                        TempInfo.setLoginFlag(0)
                        dbmgr.updatePassWord(TempInfo)
                        
                        let okalert = UIAlertController(title: "", message: "비밀번호를 초기화했습니다.", preferredStyle: UIAlertControllerStyle.Alert)
                        self.presentViewController(okalert, animated: false, completion: nil)
                        okalert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: nil))
                        
                }))
            }
            else if indexPath.row == 2{
                // 메일 등록하기 // 디비에 메일이 등록되어있는지 확인
                if dbmgr.getMyInfo().getMail() == ""{
                    inputMailAlert()
                }
                else{
                    // 메일이 등록되어있음을 알리고 수정 여부 확인
                    checkMailAlert(dbmgr.getMyInfo().getMail())
                }
            }
        }
        // diary database
        else if indexPath.section == 1{
            // 내 다이어리 텍스트로 내보내기 - 메일로 연동됩니다. (등록된 메일이 자동기입)
            if indexPath.row == 0{
                // txt파일을 생성하고 그 파일을 attach하는 방식
                makeDiaryToFile()
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
                //load()
            }
            // diary backup - server 서버로 백업합니다.
            else if indexPath.row == 1{
                let alert = UIAlertController(title: "Diary BackUp", message: "현재 다이어리를 백업하시겠습니까?", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alert, animated: false, completion: nil)
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default,
                    handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler:
                    {action in
                        self.jsonMgr.backup() // JSONMgr에서 backup메소드를 통해 진행
                        let okalert = UIAlertController(title: "", message: "현재의 다이어리를 백업했습니다.", preferredStyle: UIAlertControllerStyle.Alert)
                        self.presentViewController(okalert, animated: false, completion: nil)
                        okalert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: nil))
                        
                }))
            }
        }
        
        //reset & restore
        else {
            // 현재 sqlite DB의 Diary테이블을 모두 날립니다.
            if indexPath.row == 0{
                let alert = UIAlertController(title: "되돌릴 수 없습니다", message: "다이어리를 초기화하시겠습니까?", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alert, animated: false, completion: nil)
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default,
                    handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler:
                    {action in
                        let dbmgr = dbMgr()
                        dbmgr.resetDiary()
                        let okalert = UIAlertController(title: "", message: "다이어리를 초기화했습니다.", preferredStyle: UIAlertControllerStyle.Alert)
                        self.presentViewController(okalert, animated: false, completion: nil)
                        okalert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: nil))
                        
                }))
                
            }
            // diary Restore - 서버에서 백업해둔 다이어리정보들을 리셋합니다.
            else if indexPath.row == 1 {
                let alert = UIAlertController(title: "Diary Restore", message: "백업해둔 다이어리를 불러오시겠습니까?", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alert, animated: false, completion: nil)
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default,
                    handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler:
                    {action in
                        self.jsonMgr.restore() // jsonMgr의 restore메소드 호출
                        let okalert = UIAlertController(title: "", message: "최신 백업본으로 초기화합니다.", preferredStyle: UIAlertControllerStyle.Alert)
                        self.presentViewController(okalert, animated: false, completion: nil)
                        okalert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: nil))
                        
                }))
            }
        }
        // 테이블뷰는 바로 deselect화 되도록 (highlight 제거)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // SettingTableView의 unwind segue
    @IBAction func ModifyPassWordToSettings(segue:UIStoryboardSegue) {
    }


    // 메일 컴포져 생성
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        let dbmgr = dbMgr()
        let emailaddress = dbmgr.getMyInfo().getMail()
        mailComposerVC.setToRecipients([emailaddress])
        mailComposerVC.setSubject("SecretDiary BackUp file")
        
        let file = "SecretDiaryText.txt"
        if let dirpath : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true){
            let dir = dirpath[0] as String//documents directory
            let path = (dir as NSString).stringByAppendingPathComponent(file);
            if let sendingfile = NSData(contentsOfFile: path){
                // data를 attachment합니다. (네이버 메일에서는 첨부파일로 들어감)
                mailComposerVC.addAttachmentData(sendingfile, mimeType: "text/plain", fileName: file)
            }
        }
        return mailComposerVC
    }
    
    // 메일을 보낼 수 없는 경우 에러 alert
    func showSendMailErrorAlert() {
        let failalert = UIAlertController(title: "메일을 보낼 수 없습니다.", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(failalert, animated: false, completion: nil)
        failalert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: nil))
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // 20082412 를 2008/24/12와 같이 자르는 역할을 하는 메소드입니다. (swift는 substring에 매우 야박함..)
    func dateToString(Date: String)->String!{
        let range1 = Date.startIndex.advancedBy(0)..<Date.endIndex.advancedBy(-4)
        let Tyear = Date[range1]
        let range2 = Date.startIndex.advancedBy(4)..<Date.endIndex.advancedBy(-2)
        let Tmonth = Date[range2]
        let range3 = Date.startIndex.advancedBy(6)..<Date.endIndex
        let Tday = Date[range3]
        let returnString = String("\(Tyear)년 \(Tmonth)월 \(Tday)일\n")
        return returnString
    }
    
    
    // 현재의 일기정보를 File로 만드는 메소드
    func makeDiaryToFile(){
        // 다이어리의 오브젝트를 모두 참조하면서... String으로 묶은 후 txt파일로 만듬
        let AllDiary = dbmgr.select_AllDiary()
        let file = "SecretDiaryText.txt"
        let daydelimeter = "\n***************************************\n"
        
        if let dirpath : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true){
            let dir = dirpath[0] as String //나의 앱의 document directory를 가리킴
            let path = (dir as NSString).stringByAppendingPathComponent(file);
            var fullDiary:String! = ""
            do{
                for Diary in AllDiary{
                    // 파일을 열어놓고 계속 쓰는방법 // 하나의 스트링으로 만들어 쓰는 방법 중 후자 선택
                    fullDiary = String("\(fullDiary)" + daydelimeter)
                    let dayString = dateToString(Diary.Date)
                    fullDiary = String("\(fullDiary)" + dayString)
                    
                    let WeatherFeelString = String("날씨 : \(WeatherString[Diary.Weather]), 기분 : \(FaceString[Diary.Face])\n")
                    fullDiary = String("\(fullDiary)" + WeatherFeelString)
    
                    let SubjectString = String("제목 : \(Diary.Subject)\n")
                    fullDiary = String("\(fullDiary)" + SubjectString)
                    
                    
                    let mutacontent = NSKeyedUnarchiver.unarchiveObjectWithData(Diary.Content)
                    let MutString = mutacontent as! NSMutableAttributedString
                    let TextString = MutString as NSAttributedString
                    let ContentString = TextString.string
                    fullDiary = String("\(fullDiary)" + ContentString)
                    
                }
                try fullDiary.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch{
                // 파일생성실패 alert 띄우기
                print("NONO")
                
            }
        }
    }
    
    // 메일등록하기를 위한 메소드 (alert with textfield를 이용하여 메일주소를 입력하게 하고 DB 유저테이블 갱신)
    func inputMailAlert(){
        let alert = UIAlertController(title: "Registered Email", message: "이메일을 입력하세요", preferredStyle:  UIAlertControllerStyle.Alert)
        var mailstring:String!
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "example@apple.com"
            textField.secureTextEntry = false
        })
        
        alert.addAction(UIAlertAction(title: "Cancle", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
            (alertAction:UIAlertAction!) in
            mailstring = alert.textFields![0].text
            
            let dbmgr = dbMgr()
            let willmodifyInfo = dbmgr.getMyInfo()
            willmodifyInfo.setMail(mailstring)
            
            dbmgr.updatePassWord(willmodifyInfo)
            
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    // 이미 메일이 등록된경우 - 수정을 요구하고 다시 이메일을 등록할 수 있게 함
    func checkMailAlert(existMail: String){
        let alert = UIAlertController(title: "Already registered \(existMail)", message: "수정하시겠습니까?", preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancle", style: UIAlertActionStyle.Cancel, handler: nil))
        //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: modifyhandler))
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alertAction:UIAlertAction!) in
        self.inputMailAlert()} ))
        
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func modifyhandler(alert: UIAlertAction){
        inputMailAlert()
    }
    
    

}
