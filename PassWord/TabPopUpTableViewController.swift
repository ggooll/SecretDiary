//
//  TabPopUpTableViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 11..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit

// revealviewController에 의해 보일 탭테이블뷰
class TabPopUpTableViewController: UITableViewController {
    
    @IBOutlet weak var cell1:UITableViewCell!
    @IBOutlet weak var cell2:UITableViewCell!
    @IBOutlet weak var cell3:UITableViewCell!
    @IBOutlet weak var cell4:UITableViewCell!
    @IBOutlet weak var cell5:UITableViewCell!
    @IBOutlet weak var cell6:UITableViewCell!
    @IBOutlet weak var table:UITableView!
    
    var LoginAuth:IdentificationInfo!
    var dbmgr:dbMgr!
    var DiaryArray:[DiaryObject] = [DiaryObject]()
    
    
    
    override func viewDidLoad() {
        LoginAuth = IdentificationInfo()
        LoginAuth.setLoginFlag(1)
        
        super.viewDidLoad()
        // 각 스태틱셀 및 테이블뷰를 따로관리
        let cellcolor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
        table.backgroundColor = cellcolor
        cell1.backgroundColor = cellcolor
        cell2.backgroundColor = cellcolor
        cell3.backgroundColor = cellcolor
        cell4.backgroundColor = cellcolor
        cell5.backgroundColor = cellcolor
        cell6.backgroundColor = cellcolor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // 세규는 스토리보드에서 모두 push로 연결되어있음
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "PopToMain"{
            let destinationNavigationController = segue.destinationViewController as! MainNaviController
            let targetController = destinationNavigationController.topViewController as! MainViewController
            targetController.LoginAuth = self.LoginAuth
        }
        
        if segue.identifier == "PopToMyDiary"{

        }
        
        if segue.identifier == "PopToCalendar"{
  
        }
        
    }
    
    // About unwind segue
    @IBAction func AboutToPop(segue:UIStoryboardSegue) {
    }
    
    // 선택되면 highlight효과가 끝나지않음 - 바로 deselect시켜줘야댐 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    

}
