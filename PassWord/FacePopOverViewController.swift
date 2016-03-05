//
//  FacePopOverViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 28..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit


// 얼굴버튼이 눌렸을때 나오는 popover View
// 눌린 버튼을 Int값으로 가지고 넘어갑니다.
// DB에도 해당정보는 1~5의 값으로 가지고 있게 하였습니다.
class FacePopOverViewController: UIViewController {

    @IBOutlet weak var PlaceHolder: UIView!
    
    @IBOutlet weak var normal: UIButton!
    @IBOutlet weak var smile: UIButton!
    @IBOutlet weak var bad: UIButton!
    
   
    @IBOutlet weak var cry: UIButton!
    @IBOutlet weak var angry: UIButton!
    
    var selectedImage:String!
    var selectedNum:Int!
    
    let FaceImage:[String]! = ["feel_normal","feel_smile","feel_bad","feel_cry","feel_angry"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func PressNormal(sender:AnyObject){
        selectedNum = 0
        selectedImage = FaceImage[0]
        self.performSegueWithIdentifier("FaceToEdit", sender: self)
    }
    
    @IBAction func PressSmile(sender:AnyObject){
        selectedNum = 1
        selectedImage = FaceImage[1]
        self.performSegueWithIdentifier("FaceToEdit", sender: self)
    }
    
    @IBAction func PressBad(sender:AnyObject){
        selectedNum = 2
        selectedImage = FaceImage[2]
        self.performSegueWithIdentifier("FaceToEdit", sender: self)
    }
    
    @IBAction func PressCry(sender:AnyObject){
        selectedNum = 3
        selectedImage = FaceImage[3]
        self.performSegueWithIdentifier("FaceToEdit", sender: self)
    }
    
    @IBAction func PressAngry(sender:AnyObject){
        selectedNum = 4
        selectedImage = FaceImage[4]
        self.performSegueWithIdentifier("FaceToEdit", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "FaceToEdit"){
            let destinationController = segue.destinationViewController as! WriteViewController
            let selectImage = UIImage(named: selectedImage)
            destinationController.FaceBtn.setImage(selectImage, forState: .Normal)
            destinationController.FaceFlag = selectedNum
        }
    }
    

}
