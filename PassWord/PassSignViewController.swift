//
//  PassSign.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 6..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import LocalAuthentication
import Foundation
import UIKit


// PassCode 뷰를 위한 컨트롤러 

class PassSignViewController: UIViewController{
    // IBOutlet 들
    @IBOutlet weak var BackGroundImage: UIImageView!
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
    var ButtonV:[UIButton] = []
    var LoginAuth:IdentificationInfo!
    var dbmgr:dbMgr!
    var wordCount:Int = 0   // 비밀번호 4자리 카운트
    var intergratedPassWord = ""  // 모인 비밀번호 String
    
    // 같은속성의 것들을 배열로 관리하기 위함
    func InVector(){
        PlaceHolderV = [Placeholder1, Placeholder2, Placeholder3, Placeholder4]
        ButtonV = [btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9]
    }
    
    // placeView의 배경색을 흰색으로 이니셜
    func initPlaceview(){
        Placeholder1.backgroundColor = UIColor.whiteColor()
        Placeholder2.backgroundColor = UIColor.whiteColor()
        Placeholder3.backgroundColor = UIColor.whiteColor()
        Placeholder4.backgroundColor = UIColor.whiteColor()
    }
    
    // 버튼과 플레이스홀더의 크기와 색상등을 초기화합니다.
    func initButton(){
        for item in ButtonV{
            item.layer.cornerRadius = 0.5 * item.layer.bounds.size.width
            item.layer.masksToBounds = true
            item.layer.borderWidth = 1.5
            item.layer.borderColor = UIColor.whiteColor().CGColor
        }
        
        for item in PlaceHolderV{
            item.layer.cornerRadius = 0.5 * item.layer.bounds.size.width
            item.layer.masksToBounds = true
            item.backgroundColor = UIColor.whiteColor()
        }
    }
    
    
    // 백그라운드 뷰 초기화 및 버튼 초기화함수 호출
    func initPassView(){
        let image = UIImage(named: "in-the-diamonds-fields.jpg")
        BackGroundImage.image = image
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.BackGroundImage.addSubview(blurEffectView)
        initButton()
    }
    
    // 홀더의 색깔을 채워줌
    func checkHolder(num: Int){
        PlaceHolderV[num-1].backgroundColor =  UIColor.init(red:0.44, green: 0.66, blue:0.86, alpha:1.0)
        PlaceHolderV[num-1].layer.cornerRadius = PlaceHolderV[num-1].layer.bounds.width * 0.5
    }
    
    // 값을 초기화 해줌
    func initHolder(){
        intergratedPassWord = ""
        wordCount = 0
    }
    
    // 버튼이 눌렸을때마다 비밀번호 카운트와 모인 비밀번호스트링을 묶는 방식...
    @IBAction func clicked(sender: UIButton){
        self.wordCount++
        self.intergratedPassWord += sender.currentTitle!

        switch wordCount{
        case 4 :
            // 4글자가 모인경우 검사함
            checkHolder(4)
            if intergratedPassWord == dbmgr.checkPassword(){
                // 맞았다면
                LoginAuth.setLoginFlag(1)
                performSegueWithIdentifier("PassOK", sender: nil)
                break
            }
            // 틀린경우
            initHolder()
            errorPassword()
            initPlaceview()
            break
            
        default :
            checkHolder(wordCount)
            break
        }
    }
    
    // 에러가뜰경우 플레이스홀더의 EarthQuake 모션!
    func errorPassword(){
        errorView(Placeholder1)
        errorView(Placeholder2)
        errorView(Placeholder3)
        errorView(Placeholder4)
    }
    
    // 각각이 따로 흔들림 - 겉을 감싼 뷰를 흔들경우 내부것이 흔들리지 않았엇음
    func errorView(Placeholder: UIView){
        Placeholder.backgroundColor = UIColor.redColor()
        let shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.02 // Duration 내
        shake.repeatCount = 8  // repeatCount만큼 흔들림
        shake.autoreverses = true
        // from -5부터 to +5까지 좌우로
        let from_point = CGPointMake(Placeholder.center.x-5, Placeholder.center.y)
        let from_value = NSValue(CGPoint: from_point)
        let to_point = CGPointMake(Placeholder.center.x+5, Placeholder.center.y)
        let to_value = NSValue(CGPoint: to_point)
        shake.fromValue = from_value
        shake.toValue = to_value
        Placeholder.layer.addAnimation(shake, forKey: "position")
    }
    

    ///* View Did Load *//////
    override func viewDidLoad() {
        dbmgr = dbMgr()
        initUserInfo()
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
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "PassOK"){
            let destinationController = segue.destinationViewController as! MainViewController
            destinationController.LoginAuth = self.LoginAuth
        }
    }
    
    // 수업시간에 배운 NSUserDefaults를 이용하여 
    func initUserInfo(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let isVisitFirst = defaults.boolForKey("isVisitFirst")
        if isVisitFirst == false {
            dbmgr.initMyinfoTable()
            defaults.setBool(true, forKey: "isVisitFirst")
        }
    }
    
    
    // Touch ID 인증 - 책 참조
    @IBAction func TouchIDBtn(sender: UIButton) {
        
        // LAContext를 생성해야 합니다. Apple에서 터치아이디를 유저들이 개발할 수 있게 만들어 줬다고 함
        let authenticationContext = LAContext()
        var error:NSError?
        
        // 디바이스가 터치아이디를 사용가능한지를 먼저 검사함니다.
        guard authenticationContext.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) else {
            showAlertViewIfNoBiometricSensorHasBeenDetected()
            return
        }
        
        // 지문을 검사합니다.
        authenticationContext.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Finger Print Check",
            reply: { [unowned self] (success, error) -> Void in
                if( success ) {
                    // 지문이 올바르다면 모달을 내려줍니다.
                    self.LoginAuth.setLoginFlag(1)
                    self.performSegueWithIdentifier("PassOK", sender: nil)
                    
                }else {
                    // 올바르지않다면 에러메시지를 띄웁니다
                    if let error = error {
                        let message = self.errorMessageForLAErrorCode(error.code)
                        self.showAlertViewAfterEvaluatingPolicyWithMessage(message)
                    }
                }
            })
        
    }
    
    // touchId 지원 불가 alert용
    func showAlertViewIfNoBiometricSensorHasBeenDetected(){
        showAlertWithTitle("Error", message: "This device does not have a TouchID sensor.")
    }
    
    // error 발생시 메시지
    func showAlertViewAfterEvaluatingPolicyWithMessage( message:String ){
        showAlertWithTitle("Error", message: message)
    }
    
    // touch 인증 alert를 띄움
    func showAlertWithTitle( title:String, message:String ) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertVC.addAction(okAction)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
    }
    
    // error코드에 대한 error메시지 할당(구글 참조 - 해당 에러에맞는 값을 띄워주기위해 꼭 필요 - 사용자에게 alert로 보여짐)
    func errorMessageForLAErrorCode( errorCode:Int ) -> String{
        var message = ""
        switch errorCode {
        case LAError.AppCancel.rawValue:
            message = "Authentication was cancelled by application"
        case LAError.AuthenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
        case LAError.InvalidContext.rawValue:
            message = "The context is invalid"
        case LAError.PasscodeNotSet.rawValue:
            message = "Passcode is not set on the device"
        case LAError.SystemCancel.rawValue:
            message = "Authentication was cancelled by the system"
        case LAError.TouchIDLockout.rawValue:
            message = "Too many failed attempts."
        case LAError.TouchIDNotAvailable.rawValue:
            message = "TouchID is not available on the device"
        case LAError.UserCancel.rawValue:
            message = "The user did cancel"
        case LAError.UserFallback.rawValue:
            message = "The user chose to use the fallback"
        default:
            message = "Did not find error code on LAError object"
        }
        return message
    }
    
    
    
    
}