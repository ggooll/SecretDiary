//
//  AppDelegate.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 6..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // RGB 0/62/96을 앱의 심볼칼라로 정하고 모두 통일
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UINavigationBar.appearance().barTintColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
        // 틴트컬러 = 글자의 색깔
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        // 텍스트의 폰트를 지정해주는 코드
        if let barFont = UIFont(name: "Zapf Dingbats", size: 22.0) {
            UINavigationBar.appearance().titleTextAttributes =
                [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName:barFont]
        }
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // appearance  외관
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UIToolbar.appearance().barTintColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

