//
//  WeatherPopOverViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 28..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit

// 날씨버튼이 눌렸을때 나오는 popover View 
// 눌린 버튼을 Int값으로 가지고 넘어갑니다. 
// DB에도 해당정보는 1~5의 값으로 가지고 있게 하였습니다.
class WeatherPopOverViewController: UIViewController {

    @IBOutlet weak var PlaceHolder: UIView!
    @IBOutlet weak var sunny: UIButton!
    @IBOutlet weak var cloudy: UIButton!
    @IBOutlet weak var windy: UIButton!
    @IBOutlet weak var rainy: UIButton!
    @IBOutlet weak var snowy: UIButton!
    
    var selectedImage:String!
    var selectedNum:Int!
    
    let WeatherImage:[String]! = ["weather_sunny","weather_windy","weather_rainy","weather_cloudy","weather_snow"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func PressSunny(sender:AnyObject){
        selectedNum = 0
        selectedImage = WeatherImage[0]
        self.performSegueWithIdentifier("WeatherToEdit", sender: self)
    }
    
    @IBAction func PressCloudy(sender:AnyObject){
        selectedNum = 3
        selectedImage = WeatherImage[3]
        self.performSegueWithIdentifier("WeatherToEdit", sender: self)
    }
    
    @IBAction func PressWindy(sender:AnyObject){
        selectedNum = 1
        selectedImage = WeatherImage[1]
        self.performSegueWithIdentifier("WeatherToEdit", sender: self)
    }
    
    @IBAction func PressRainy(sender:AnyObject){
        selectedNum = 2
        selectedImage = WeatherImage[2]
        self.performSegueWithIdentifier("WeatherToEdit", sender: self)
    }
    
    @IBAction func PressSnowy(sender:AnyObject){
        selectedNum = 4
        selectedImage = WeatherImage[4]
        self.performSegueWithIdentifier("WeatherToEdit", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "WeatherToEdit"){
            let destinationController = segue.destinationViewController as! WriteViewController
            let selectImage = UIImage(named: selectedImage)
            destinationController.WeatherBtn.setImage(selectImage, forState: .Normal)
            destinationController.WeatherFlag = selectedNum
        }
    }


}
