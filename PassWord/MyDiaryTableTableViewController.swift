//
//  MyDiaryTableTableViewController.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 14..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import UIKit

// 전체 다이어리를 동적 테이블뷰로 관리하는 컨트롤러
class MyDiaryTableTableViewController: UITableViewController, UISearchResultsUpdating{
    
    @IBOutlet weak var PopBtn: UIBarButtonItem!
    var dbmgr:dbMgr!
    var DiaryArray:[DiaryObject]!
    var PassDateInfo:WriteDiaryInfo!
    var searchController: UISearchController!
    var searchResults:[DiaryObject] = []
    
    var SelectedDiary:DiaryObject!
    let WeatherImage:[String]! = ["weather_sunny","weather_windy","weather_rainy","weather_cloudy","weather_snow"]
    let FaceImage:[String]! = ["feel_normal","feel_smile","feel_bad","feel_cry","feel_angry"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 탭테이블뷰를 위한 연결 및 swipe 움직임
        PopBtn.target = self.revealViewController()
        PopBtn.action = ("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        dbmgr = dbMgr()
        DiaryArray = dbmgr.select_AllDiary()
        
        // SearchController를 연결
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
    }
    

    
    override func viewWillAppear(animated: Bool) {
        // 뷰가 보일때마다 디비를 새로 업데이트하고 ㅂ테이블에 반영
        dbmgr = dbMgr()
        DiaryArray = dbmgr.select_AllDiary()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 섹션은 1개
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // searchController 작동시
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        } else {
            return DiaryArray.count
        }
    }
    
    
    
    // 각 셀에 대해서 설정합니다 
    // MyDiaryCell이 하나의 셀이되고 identifier를 이용하여 재사용됨!
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiaryCell", forIndexPath: indexPath) as! MyDiaryCell
        let diaryObject = (searchController.active) ? searchResults[indexPath.row] : DiaryArray[indexPath.row]
        
        let range1 = diaryObject.Date.startIndex.advancedBy(0)..<diaryObject.Date.endIndex.advancedBy(-4)
        let Tyear = diaryObject.Date[range1]
        
        let range2 = diaryObject.Date.startIndex.advancedBy(4)..<diaryObject.Date.endIndex.advancedBy(-2)
        let Tmonth = diaryObject.Date[range2]
        
        let range3 = diaryObject.Date.startIndex.advancedBy(6)..<diaryObject.Date.endIndex
        let Tday = diaryObject.Date[range3]
        
        
        cell.DateLabel.text = Tyear + "년 " + Tmonth + "월 " + Tday + "일"
        cell.SubjectLabel.text = diaryObject.Subject
        
        cell.WeatherImage.image = UIImage(named: WeatherImage[diaryObject.Weather])
        cell.WeatherImage.image = cell.WeatherImage.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.WeatherImage.tintColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)

        cell.FaceImage.image = UIImage(named: FaceImage[diaryObject.Face])
        cell.FaceImage.image = cell.FaceImage.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.FaceImage.tintColor = UIColor(red: 0/255, green: 62/255, blue: 96/255, alpha: 1.0)
    
        return cell
    }
    
    
    
    
    // MyDiaryTable에는 이미 작성된 일기만이 가능하므로 View창으로만 접근이 가능함 - 날짜정보를 같이 보냄
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "MyDiaryToEdit"{
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destinationController = segue.destinationViewController as! EditDiaryViewController
                let diary = (searchController.active) ? searchResults[indexPath.row] : DiaryArray[indexPath.row]
                
                // 스트링을 range를 이용하여 20151219를 2015/12/19와 같이 자르기 위함..
                let range1 = diary.Date.startIndex.advancedBy(0)..<diary.Date.endIndex.advancedBy(-4)
                let Tyear = diary.Date[range1]
                
                let range2 = diary.Date.startIndex.advancedBy(4)..<diary.Date.endIndex.advancedBy(-2)
                let Tmonth = diary.Date[range2]
                
                let range3 = diary.Date.startIndex.advancedBy(6)..<diary.Date.endIndex
                let Tday = diary.Date[range3]
                
                destinationController.SelectedDayInfo = WriteDiaryInfo(year: Tyear, month: Tmonth, day: Tday);
            }
        }
    }
    
    // unwind segue
    @IBAction func WriteToMyDiary(segue:UIStoryboardSegue) {
    }
    

    // 테이블뷰의 좌측 swipe - delete를 위함 (alert를 띄우고 삭제여부를 결정)
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        if editingStyle == .Delete {
            let alert = UIAlertController(title: "", message: "일기를 삭제하시겠습니까?", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: false, completion: nil)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {action in
                    tableView.beginUpdates()
                    self.dbmgr.delete(self.DiaryArray[indexPath.row].Date)
                    self.DiaryArray = self.dbmgr.select_AllDiary()
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    tableView.endUpdates()
                }))
        }
    }
    

    // 검색시 매칭을 검사
    func filterContentForSearchText(searchText: String) {
        searchResults = DiaryArray.filter({ ( diary: DiaryObject) -> Bool in
            let mutacontent = NSKeyedUnarchiver.unarchiveObjectWithData(diary.Content)
            let MutString = mutacontent as! NSMutableAttributedString
            let TextString = MutString as NSAttributedString
            let strContent = TextString.string
            let ContentMatch = strContent.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            // Content는 이미지가 섞인 attributedString이므로 고유 String만을 뽑아내기위한 과정이 매우 복잡하다.
            let SubjectMatch = diary.Subject.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
        
            return  SubjectMatch != nil || ContentMatch != nil
        })
    }
    
    // searchController의 결과를 테이블뷰에 반영합니다.
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        filterContentForSearchText(searchText!)
        tableView.reloadData()
    }
    
    // searchConroller의 active여부
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController.active { return false }
        else { return true }
    }
    
    
    
    
    
}
