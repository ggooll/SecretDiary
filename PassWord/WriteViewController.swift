//
//  WriteViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 12. 10..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit

// 일기를 작성하는 뷰 컨트롤러
class WriteViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ContentText: UITextView!
    @IBOutlet weak var SubjectText: UITextField!
    
    @IBOutlet weak var DoneBtn: UIBarButtonItem!
    
    @IBOutlet weak var WeatherBtn: UIButton!
    @IBOutlet weak var FaceBtn: UIButton!
    @IBOutlet weak var EditToolBar: UIToolbar!
    @IBOutlet weak var DayLabel: UILabel!
    
    var SelectedDay:String!
    var UpdateFlag:Bool! = true
    var IsStartEditFlag:Bool! = false
    
    var WeatherFlag: Int! = 0
    var FaceFlag: Int! = 0
    var dbmgr:dbMgr!
    
    let WeatherImage:[String]! = ["weather_sunny","weather_windy","weather_rainy","weather_cloudy","weather_snow"]
    let FaceImage:[String]! = ["feel_normal","feel_smile","feel_bad","feel_cry","feel_angry"]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EditToolBar.barTintColor = UIColor.blackColor()
        
        dbmgr = dbMgr()
        initLabel()
        initTextView()
        if initLoadView() == false{
            setPlaceHolderTextView()
        }
        
        self.addDoneButtonOnKeyboard()
        ContentText.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Load Diary - MainView의 Content TextView와 방식이 같음
    // 받아온 NSData를 NSAttributeString으로 변경하여 내부 attachment들을 다시 재정비하는 식으로 뷰를 꾸림
    // 이미지를 디비에 저장했다가 다시 불러오면 설정했던 bound를 무시하고 원래크기로 뿌려주기때문에 반드시 필요...
    func initLoadView() -> Bool{
        if let LoadObject = dbmgr.select_SelectedDay(SelectedDay){
            SubjectText.text = LoadObject.Subject
            
            if let mutacontent = NSKeyedUnarchiver.unarchiveObjectWithData(LoadObject.Content){
                let MutString = mutacontent as! NSMutableAttributedString
                
                MutString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, MutString.length), options: .LongestEffectiveRangeNotRequired) { (value, range, stop) -> Void in
                    if let attachement = value as? NSTextAttachment {
                        let image = attachement.imageForBounds(attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location+1)
                    
                        let newAttribut = NSTextAttachment()
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
        }
        else{
            return false
        }
        
        return true
    }
    
    
    
    
    // 날짜를 substring으로 잘라서 label에 보여줌
    func initLabel(){
        let range1 = SelectedDay.startIndex.advancedBy(0)..<SelectedDay.endIndex.advancedBy(-4)
        let Tyear = SelectedDay[range1]
        
        let range2 = SelectedDay.startIndex.advancedBy(4)..<SelectedDay.endIndex.advancedBy(-2)
        let Tmonth = SelectedDay[range2]
        
        let range3 = SelectedDay.startIndex.advancedBy(6)..<SelectedDay.endIndex
        let Tday = SelectedDay[range3]
        DayLabel.text = String("\(Tyear)년 \(Tmonth)월 \(Tday)일의 일기입니다.")
    }
    
    
    // 내용 TextView 이니셜라이즈
    func initTextView(target: UITextView){
        target.delegate = self
        target.editable = true
        target.textContainer.maximumNumberOfLines = 0
        target.textContainer.lineFragmentPadding = 0
        target.textContainerInset = UIEdgeInsetsZero
        target.layer.borderWidth = 0.5
        target.layer.borderColor = UIColor.clearColor().CGColor
        target.backgroundColor = UIColor.clearColor()
        target.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        target.clipsToBounds = true
    }
    
    // 제목 텍스트 필드의 이니셜라이즈
    func initTextView(){
        initTextView(ContentText)
        SubjectText.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0);
        SubjectText.backgroundColor = UIColor.clearColor()
        SubjectText.layer.borderWidth = 0.5
        SubjectText.layer.borderColor = UIColor.clearColor().CGColor
        SubjectText.clipsToBounds = true
    }
    
    // 텍스트뷰에 Placeholder 위치
    func setPlaceHolderTextView(){
        ContentText.text = "Content"
        ContentText.textColor = UIColor.lightGrayColor()
    }
    
    // TextView의 delegate를 이용하여 에디팅을 시작했다면 placeholder를 지워줌
    func textViewDidBeginEditing(textView: UITextView) {
        IsStartEditFlag = true
        textView.editable = true
        textView.autoresizingMask = .FlexibleHeight
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    
    //@IBAction 이미지를 불러오는 메소드(실습 참조) - camera와 photolibrary
    func addImage(){
        var imagepicktype:UIImagePickerControllerSourceType!
        let optionMenu = UIAlertController(title: nil, message: "사진 가져오기", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        
        let photoHandler = { (action:UIAlertAction!) -> Void in
            imagepicktype = UIImagePickerControllerSourceType.PhotoLibrary
            if UIImagePickerController.isSourceTypeAvailable(imagepicktype) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                imagePicker.sourceType = imagepicktype
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: photoHandler)
        optionMenu.addAction(photoLibraryAction)
        
        let cameraHandler = { (action:UIAlertAction!) -> Void in
            imagepicktype = UIImagePickerControllerSourceType.Camera
            if UIImagePickerController.isSourceTypeAvailable(imagepicktype) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.delegate = self // 너의 델리게이트가 나야.....
                imagePicker.sourceType = imagepicktype
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: cameraHandler)
        optionMenu.addAction(cameraAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    
    
    // 선택을 통지받을 메소드 - 골르는게 끝났을때 실행 didFinishPicking
    // 인포에 피킹된 미디어에 대한 정보가 들어있따.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // info딕셔너리의 UIImagePickerControllerOriginalImage라는 키값을 가지고 있는것임.... (라이브러리 참조)
        let imageView = info[UIImagePickerControllerOriginalImage] as? UIImage
        let image = UIImageView(image: imageView)
        image.contentMode = UIViewContentMode.ScaleAspectFill
        
        let textAttachment:NSTextAttachment = NSTextAttachment(data: nil, ofType: nil)
        
        
        //textAttachment.image = image.image
        textAttachment.image = UIImage(data: UIImageJPEGRepresentation(image.image!, 0.0)!)
        
        textAttachment.bounds = CGRectMake(0.0, 0.0, self.ContentText.bounds.width-20.0, self.ContentText.bounds.width-20.0)
        
        // attributeText를 가져와 MutuableAttributedString화 함
        let initialText = ContentText.attributedText;
        let newText = NSMutableAttributedString(attributedString: initialText);
        
        // 현재 텍스트의 커서포인트를 가져옴 - 이미지를 그곳에 삽입하기 위함
        let textRange:UITextRange! = ContentText.selectedTextRange
        let beginning:UITextPosition! = ContentText.beginningOfDocument
        let location:Int = ContentText.offsetFromPosition(beginning, toPosition: textRange.start)
        
        // atIndex에 처음부터 현재 커서까지의 오프셋 = location
        // attachment를 해당위치에 붙이고 개행문자 삽입
        newText.insertAttributedString(NSAttributedString(attachment: textAttachment), atIndex: location)
        ContentText.attributedText = newText;
        ContentText.insertText("\n")
        
        // 프리젠트한 것을 다시 내려줌 (포토라이브러리 내려버림)
        dismissViewControllerAnimated(true, completion: nil)
        
        // 바로 에디팅하던 정보를 유지하기위해 - becomeFirstResponser를이용하여 지속가능하도록 함
        let start:UITextPosition! = ContentText.positionFromPosition(ContentText.beginningOfDocument, offset: location+1)
        let end:UITextPosition! = ContentText.positionFromPosition(start, offset: 0)
        let newRange:UITextRange = ContentText.textRangeFromPosition(start, toPosition: end)!
        ContentText.selectedTextRange = newRange
        ContentText.insertText("\n")
        ContentText.becomeFirstResponder()
    }
    

    // 날씨버튼을 클릭하면 popover로 여러버튼을 선택할 수 있게 한다.
    // 스토리보드의 view를 부분만 잘라오는 구조로 되어있다.
    @IBAction func WeatherBtn(sender: AnyObject){
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("WeatherPopOver") as! WeatherPopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(200, 55)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = (sender as! UIView)
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            popoverController.permittedArrowDirections = .Unknown
            popoverController.delegate = self
        }
        presentViewController(popoverVC, animated: true, completion: nil)
    }
    
    // 얼굴 버튼을 클릭하면 popover로 여러버튼을 선택할 수 있게 한다.
    @IBAction func FaceBtn(sender: AnyObject){
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("FacePopOver") as! FacePopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(200, 55)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = (sender as! UIView)
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 0, height:0)
            popoverController.permittedArrowDirections = .Unknown
            popoverController.delegate = self
        }
        presentViewController(popoverVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    // 텍스트가 채워져있는지 아닌지 검사..
    func isFilledText()->Bool{
        // 아무짓도안했다면 false를 리턴해야하는데... 알아차리기가 힘듬 
        // 기본 제공값이 변경되지않았으면 잘못눌렀다고 가정
        if ContentText.text == "Content"{
            if SubjectText.text == ""{
                if WeatherFlag == 0 && FaceFlag == 0{
                    print("^^")
                    return false
                }
            }
        }
        return true
    }
    
    

    
    // 저장할경우 DB에 업데이트시키고 unwind함
    @IBAction func PressDoneBtn(sender: AnyObject){
        if isFilledText() == true{
            let tempcontent = NSMutableAttributedString(attributedString: ContentText.attributedText)
            let contentdata = NSKeyedArchiver.archivedDataWithRootObject(tempcontent)
            //let content = contentdata.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            let SaveDiaryObject = DiaryObject(date: SelectedDay, subject: SubjectText.text!, content: contentdata, weather: WeatherFlag, face: FaceFlag)
            if UpdateFlag == true{ dbmgr.updateDiaryData(SaveDiaryObject) }
            else{ dbmgr.updateDiaryData(SaveDiaryObject) }
        }
        self.performSegueWithIdentifier("WriteToBack", sender: self)
    }
    
    // 그냥 닫을경우 unwind
    @IBAction func PressCloseBtn(sender: AnyObject){
        self.performSegueWithIdentifier("WriteToBack", sender: self)
    }
    
    // popover에서의 unwindsegue
    @IBAction func WeatherToEdit(segue:UIStoryboardSegue) {
    }
    
    @IBAction func FaceToEdit(segue:UIStoryboardSegue){
    }

    // 키보드위로 툴바를 위치시키기 위한 메소드 - Done, image버튼이 위치
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 30))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        doneToolbar.barTintColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        let Img = UIImage(named: "image-1")
        let image: UIBarButtonItem = UIBarButtonItem(image: Img, style: UIBarButtonItemStyle.Plain, target: nil, action: Selector("addImage"))
        
        var items:[AnyObject]! = [UIBarButtonItem]()
        items.append(image)
        items.append(flexSpace)
        items.append(done)
        doneToolbar.setItems(items as? [UIBarButtonItem], animated: false)
        doneToolbar.sizeToFit()
        
        self.ContentText.inputAccessoryView = doneToolbar
        
        if let accessorizedView = view as? UITextView {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        } else {
            
        }
    }
    
    

    
    // 키보드의 done버튼을 누르면 바로아래의 shouldendEditing 메소드가 호출됨
    func doneButtonAction(){
        self.textViewShouldEndEditing(ContentText)
    }
    
    // 텍스트뷰가 에디팅을 끝내는 경우의 delegate
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

    // 키보드가 보인다면 - bottumConstraint를 올려버림(위로 스크롤됨 같이)
    // 이 과정이 없다면 텍스트뷰의 아래쪽은 키보드에 가려져 쓸수없게됨 !
    func keyboardWillShow(notification: NSNotification?) {
        guard let keyboardFrame = (notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(),
            duration:NSTimeInterval = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else {
                return
        }
        bottomConstraint.constant = keyboardFrame.size.height + 10
        UIView.animateWithDuration(duration, animations: { self.view.layoutIfNeeded() },completion:nil)
    }
    
    // 키보드가 닫힌다면 - bottumConstraint를 같이 내려버림
    func keyboardWillHide(notification: NSNotification?) {
        guard let duration = (notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double) else {
            return
        }
        bottomConstraint.constant = 10
        UIView.animateWithDuration(duration, animations:{ self.view.layoutIfNeeded() }, completion:nil)
    }
    
}




