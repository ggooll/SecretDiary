//
//  MyDiaryNavigationController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 25..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit

class MyDiaryNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().barTintColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


}
