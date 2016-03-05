//
//  MainNaviController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 13..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit

class MainNaviController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().barTintColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
        
        //self.view.window?.rootViewController?.presentViewController(SWRevealViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


}
