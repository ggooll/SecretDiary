//
//  WriteDiaryViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 9..
//  Copyright © 2015년 규철 임. All rights reserved.
//


/*
import UIKit
import CVCalendar


class WriteDiaryViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    
    @IBOutlet weak var SaveBtn: UIButton!
    @IBOutlet weak var ResetBtn: UIButton!
    @IBOutlet weak var LoadBtn: UIButton!
    @IBOutlet weak var ImageBtn: UIButton!

    @IBOutlet weak var SubjectTextView: UITextField!
  // 저장 후 달력뷰로 넘어감?
    @IBOutlet weak var DoneBarBtn: UIBarButtonItem!

    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var DayLabel: UILabel!
    
    var asdf = NSData()
    
    // 오늘 이전의 날짜는 작성이 안되야 하는가?
    // 1. 일기가 작성되어있지 않은 날이라면 새로운 일기를 쓸수있는 뷰를띄운다 
    // 2. 일기가 작성된 날이라면
    
    var dbmgr: dbMgr!
    var dateInfo: WriteDiaryInfo!
    var LoginAuth: IdentificationInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTextView()
       
        
        dbmgr = dbMgr()
        print("delete")
        //dbmgr.delete_TempTable()
        print("create")
        //dbmgr.create_TempTable()

        
        
        
        
        
        dateInfo = WriteDiaryInfo(year: String(CVDate(date: NSDate()).year), month: String(CVDate(date: NSDate()).month), day: String(CVDate(date: NSDate()).day))
        DayLabel.text = "\(dateInfo.thisYear)년 \(dateInfo.thisMonth)월 \(dateInfo.thisDay)일"
    }
    
    
    func initTextView(){
        textView.delegate = self
        textView.editable = true
        //textView.text = "입력하세요"
        //textView.textColor = UIColor.lightGrayColor()
        textView.textContainer.maximumNumberOfLines = 0 // 라인 수 무한대
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsZero
        textView.layer.borderWidth = 0.5 // 윤곽선 지정
        textView.layer.borderColor = UIColor.grayColor().CGColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBar.hidden = false
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func pressSaveBtn(sender: UIButton){
        //db에 저짱하기
        print("save!")
        let tempCL = TempClass()
        tempCL.subject = SubjectTextView.text
        
        let tempcontent = NSMutableAttributedString(attributedString: textView.attributedText)
        let contentdata = NSKeyedArchiver.archivedDataWithRootObject(tempcontent)

        // contentdata는 NSData...
        asdf = contentdata
        
        /*
        contentdata.base64EncodedDataWithOptions(.EncodingEndLineWithLineFeed)
        asdf = contentdata
        */
        
        

        
        /*
        print("ContentData")
        print(contentdata)
        print("")


        let asdf = contentdata.base64EncodedDataWithOptions(.Encoding64CharacterLineLength)
       
        print("nsstr")
        print(asdf)
        print("")
        
        
        let datafrom64 = NSData.init(base64EncodedData: asdf, options: .IgnoreUnknownCharacters)
        
        print("datafrom64")
        print(datafrom64)
        print("")
        */
        

        tempCL.content = contentdata
        //dbmgr.insert_TempTable(tempCL)
    }
    
    @IBAction func pressResetBtn(sender: UIButton){
        self.textView.text = nil
        self.SubjectTextView.text = nil
    }
    
    
    
    @IBAction func pressLoadBtn(sender: UIButton){
        //db에서 불러오기 
        let tempCL = dbmgr.select_TempTable()
        self.SubjectTextView.text = tempCL.subject

        
        //let data = NSData(base64EncodedData: tempCL.content, options: .IgnoreUnknownCharacters)
        
        
        if let mutacontent = NSKeyedUnarchiver.unarchiveObjectWithData(tempCL.content){
            let MutString = mutacontent as! NSMutableAttributedString
            
            print("^+^??")
            //print(MutString)
            
            MutString.beginEditing()
            // 다시 돌면서 이미지를 작게만들어야되니..?
            
            //MutString.drawWithRect(self.textView.bounds, options: NSStringDrawingOptions.TruncatesLastVisibleLine, context: nil)
            
            
            
            let imageArray = NSMutableArray()
            let beforeMutString = NSMutableAttributedString()
            
            // 이미지의 크기를 구하는방법...? 
            
            
            MutString.enumerateAttribute(NSAttachmentAttributeName, inRange:  NSMakeRange(0, MutString.length), options: .LongestEffectiveRangeNotRequired, usingBlock:{ value, range, stop in
                if let attachment = value{
                    print(attachment)
                    if attachment.isKindOfClass(NSTextAttachment){
                        print("kyky")
                    }
                    imageArray.addObject(attachment)
                }
            })
            
            
            for img in imageArray{
                if img.isKindOfClass(NSTextAttachment){
                    
                }
            }
            

            
            
            MutString.endEditing()
            
            self.textView.attributedText = MutString as NSAttributedString
        }
        else{
            print("in mutacontent unarchive")
            //print(asdf)
        }

        

        
        
        //asdfsㅡㄴ 64로 인코딩되어있음 
       
        /*
        if let Data = NSData(base64EncodedData: asdf, options: .IgnoreUnknownCharacters){
            
            if let mutacontent = NSKeyedUnarchiver.unarchiveObjectWithData(Data){
                self.textView.attributedText = mutacontent as! NSAttributedString
            }
            else{
                print("in mutacontent is nil")
                //print(mutacontent)
            }
            
        }else{
            print("no 64 to data")
        }
        */
        
        
       
        
        
        
        //self.textView.attributedText = mutacontent?.attributedText
        
    
        
        //self.textView.text = tempCL.content
        
    }
    
    @IBAction func imagefunc(sender: UIButton!){
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
        image.contentMode = UIViewContentMode.ScaleAspectFit
        
        let textAttachment:NSTextAttachment = NSTextAttachment(data: nil, ofType: nil)
        textAttachment.image = image.image
        
        //print(image)
        //print(textAttachment.image)
        
        textAttachment.bounds = CGRectMake(0.0, 0.0, self.textView.bounds.width-20.0, self.textView.bounds.width-20.0)
        
        
        
        let initialText = textView.attributedText;
        let newText = NSMutableAttributedString(attributedString: initialText);
        
        
        let textRange:UITextRange! = textView.selectedTextRange
        let beginning:UITextPosition! = textView.beginningOfDocument
        let location:Int = textView.offsetFromPosition(beginning, toPosition: textRange.start)
        
        // atIndex에 처음부터 현재 커서까지의 오프셋 = location
        newText.insertAttributedString(NSAttributedString(attachment: textAttachment), atIndex: location)
        
        textView.attributedText = newText;
        textView.insertText("\n")
        
        // 프리젠트한 것을 다시 내려줌 (포토라이브러리 내려버림)
        dismissViewControllerAnimated(true, completion: nil)
        
        let start:UITextPosition! = textView.positionFromPosition(textView.beginningOfDocument, offset: location+1)
        let end:UITextPosition! = textView.positionFromPosition(start, offset: 0)
        let newRange:UITextRange = textView.textRangeFromPosition(start, toPosition: end)!
        textView.selectedTextRange = newRange
        textView.insertText("\n")
        textView.becomeFirstResponder()
        
        
    }
    
    
    
    
    

}


*/
