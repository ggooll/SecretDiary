//
//  SettingPassWordViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 12. 11..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit


// PassSignView와 동일한 구조로 이루어져 있음 - 비밀번호 변경을 위한 뷰
class SettingPassWordViewController: UIViewController {

    @IBOutlet weak var BackGroundImage: UIImageView!
    @IBOutlet weak var MainLable: UILabel!
    
    @IBOutlet weak var OnPlaceStuff: UIView!
    @IBOutlet weak var Placeholder1: UIView!
    @IBOutlet weak var Placeholder2: UIView!
    @IBOutlet weak var Placeholder3: UIView!
    @IBOutlet weak var Placeholder4: UIView!
    var PlaceHolderV:[UIView] = []
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn7: UIButton!
    @IBOutlet weak var btn8: UIButton!
    @IBOutlet weak var btn9: UIButton!
    @IBOutlet weak var btn0: UIButton!
    @IBOutlet weak var closebtn: UIButton!
    @IBOutlet weak var backbtn: UIButton!
    
    var ButtonV:[UIButton] = []
    var LoginAuth:IdentificationInfo!
    var dbmgr:dbMgr!
    
    var currentPassWord:String!
    var newPassWord:String!
    var numthTry:Int = 0
    
    ///* View Did Load *//////
    override func viewDidLoad() {
        dbmgr = dbMgr()
        LoginAuth = dbmgr.getMyInfo()
        currentPassWord = LoginAuth.getPassWord()
        InVector()
        initPassView()
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    func InVector(){
        PlaceHolderV = [Placeholder1, Placeholder2, Placeholder3, Placeholder4]
        ButtonV = [btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9]
    }
    
    func initPlaceview(){
        Placeholder1.backgroundColor = UIColor.whiteColor()
        Placeholder2.backgroundColor = UIColor.whiteColor()
        Placeholder3.backgroundColor = UIColor.whiteColor()
        Placeholder4.backgroundColor = UIColor.whiteColor()
    }
    
    var wordCount:Int = 0
    var intergratedPassWord = ""
    
    
    func initButtonV(item: UIButton){
        let defaultColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
        item.layer.cornerRadius = 0.5 * item.layer.bounds.size.width
        item.layer.masksToBounds = true
        item.layer.borderWidth = 1.5
        item.layer.borderColor = defaultColor.CGColor
    }
    
    
    
    func initButton(){
        let defaultColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
        for item in ButtonV{
            initButtonV(item)
        }
        //initButtonV(backbtn)
        //initButtonV(closebtn)
        for item in PlaceHolderV{
            item.layer.cornerRadius = 0.5 * item.layer.bounds.size.width
            item.layer.masksToBounds = true
            item.backgroundColor = defaultColor
        }
    }
    
    
    func initPassView(){
        initButton()
    }
    

    
    func checkCurrentPassWord()->Bool{
        if self.currentPassWord == intergratedPassWord{
            return true
        }
        return false
    }
    
    
    func checkNewPassword()->Bool{
        if self.newPassWord == intergratedPassWord{
            return true
        }
        return false
    }
    
    // 3개까지 입력후 back버튼을 누르면 방금 입력을 취소해주는 메소드 
    // count와 substring을 이용하여 간단히 구현 
    @IBAction func pressBackBtn(sender: UIButton){
        if wordCount != 0{
            wordCount--
            let range = intergratedPassWord.startIndex.advancedBy(0)..<intergratedPassWord.endIndex.advancedBy(-1)
            let bPass = intergratedPassWord[range]
            intergratedPassWord = bPass
            PlaceHolderV[wordCount].backgroundColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
        }
    }
    
    // 변경을 취소하면 unwind합니다.
    @IBAction func pressCloseBtn(sender: UIButton){
        performSegueWithIdentifier("ModifyPassWordToSettings", sender: self)
    }
    
    // 현재의비밀번호 - 바꿀비밀번호 - 바꿀비밀번호의 확인 과정을 통해 비밀번호가 변경됨 (제공되는 많은 로직을 참조)
    @IBAction func clicked(sender: UIButton){
        self.wordCount++
        self.intergratedPassWord += sender.currentTitle!
        
        switch wordCount{
        case 4 :
            checkHolder(4)
            // 비밀번호가 맞는지 검사
            if numthTry == 0{
                // 모인것과 현재비밀번호 검사 
                if checkCurrentPassWord() == true{
                    numthTry++
                    initHolder()
                    initPlaceview()
                    initButton()
                    self.MainLable.text = "새로운 비밀번호를 입력하세요"
                }
                else{
                    initHolder()
                    initPlaceview()
                    errorPassword()
                    initButton()
                }
            }
            else if numthTry == 1{
                // 새로운 비밀번호 입력
                newPassWord = intergratedPassWord
                numthTry++
                initHolder()
                initPlaceview()
                initButton()
                self.MainLable.text = "한 번 더 입력하세요"
                
            }
            else if numthTry == 2{
                // 새로운 비밀번호 확인
                if checkNewPassword() == true{
                    LoginAuth.setPassWord(newPassWord)
                    dbmgr.updatePassWord(LoginAuth)
                    performSegueWithIdentifier("ModifyPassWordToSettings", sender: self)
                }
                else{
                    initHolder()
                    errorPassword()
                    initPlaceview()
                    initButton()
                    numthTry = 0
                    self.MainLable.text = "현재 비밀번호를 입력하세요"
                }
            }
            
            
            break
            
        default :
            checkHolder(wordCount)
            break
        }
    }
    
    
    func errorPassword(){
        errorView(Placeholder1)
        errorView(Placeholder2)
        errorView(Placeholder3)
        errorView(Placeholder4)
    }
    
    func errorView(Placeholder: UIView){
        Placeholder.backgroundColor = UIColor.redColor()
        let shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.02
        shake.repeatCount = 8
        shake.autoreverses = true
        let from_point = CGPointMake(Placeholder.center.x-5, Placeholder.center.y)
        let from_value = NSValue(CGPoint: from_point)
        let to_point = CGPointMake(Placeholder.center.x+5, Placeholder.center.y)
        let to_value = NSValue(CGPoint: to_point)
        shake.fromValue = from_value
        shake.toValue = to_value
        Placeholder.layer.addAnimation(shake, forKey: "position")
    }
    
    func checkHolder(num: Int){
        PlaceHolderV[num-1].backgroundColor =  UIColor.init(red:0.44, green: 0.66, blue:0.86, alpha:1.0)
        PlaceHolderV[num-1].layer.cornerRadius = PlaceHolderV[num-1].layer.bounds.width * 0.5
    }
    
    func initHolder(){
        intergratedPassWord = ""
        wordCount = 0
    }
    


    
    
    
}
