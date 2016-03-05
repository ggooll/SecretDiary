//
//  JSONMgr.swift
//  PassWord
//
//  Created by appl on 2015. 12. 5..
//  Copyright © 2015년 규철 임. All rights reserved.
//




import Foundation

// 디비를 서버와 통신하기 위한 제이슨
class JSONMgr{
    
    var dbmgr:dbMgr!
    var data:NSData!
    
    
    func restore(){
        //let url: NSURL? = NSURL(string: "http://localhost/test.php") // JSON을 수신할 php File의 URL
        let url: NSURL? = NSURL(string: "http://darap.dothome.co.kr/json_controller.php")
        let id = "testID"  //*************************************
        
        let JSONArray: [String:AnyObject] = ["id" : id, "header" : "restore"] // JSONArray
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url!) // 헤더 설정
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject( // 전송 부분
                JSONArray, options: NSJSONWritingOptions(rawValue: 0))
        }catch{
            print("error")
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { // 결과 확인을 위한 출력부
            (data, response, error) in
            do{
                let out = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [NSDictionary]
                self.restoreInDataBase(out!)
                
            }catch{
                print("parse error")
            }
        }
        
        task.resume()
        
    }
    
    func backup()
    {
        //auth()
        dbmgr = dbMgr()
        
        let url: NSURL? = NSURL(string: "http://darap.dothome.co.kr/json_controller.php") // JSON을 수신할 php File의 URL
        
        let allDiary = dbmgr.select_AllDiary() // 모든 일기를 가져온 딕셔너리
        
        var JSONArray:[String:AnyObject] = [:] //  전송을 위한 JSON Array  선언
        var tempDataArray:[AnyObject] = []
        
        for item in allDiary{ // allDiary의 모든 DiaryObject를 JSON형식으로 변환 후에 JSONArray에 추가
            
            let jsonObject: [AnyObject]  = [
                [
                    ///"id" : "testID",
                    "date": item.Date,
                    "title": item.Subject,
                    "contents": item.Content.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)),
                    // base64  String 으로 이미지를 인코딩
                    "face": item.Face,
                    "weather": item.Weather,
                ]
            ]
            tempDataArray += jsonObject
            JSONArray.updateValue("testID", forKey: "id") //**********************************
            JSONArray.updateValue("backup", forKey: "header")
            JSONArray.updateValue(tempDataArray, forKey: "data")
        }
        
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url!) // 헤더 설정
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject( // 전송 부분
                JSONArray, options: NSJSONWritingOptions(rawValue: 0))
        }catch{
            print("error")
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { // 결과 확인을 위한 출력부
            (data, response, error) in
            let response = response as! NSHTTPURLResponse
            print(response.statusCode)
            print(NSString(data: data!, encoding: CFStringConvertEncodingToNSStringEncoding(3)))
        }
        
        task.resume()
    }
    
    
    
    
    
    func getJSON(url:NSURL)->NSData{
        return NSData(contentsOfURL: url)!
    }
    
    
    func parseJSON(input: NSData)-> [String:AnyObject]? {
        
        let output:NSDictionary;
        do{
            output = try NSJSONSerialization.JSONObjectWithData(input, options: NSJSONReadingOptions.MutableContainers) as! [String:AnyObject]
            return output as? [String : AnyObject]
        }catch{
            print("Parse error!")
        }
        return nil
    }
    
    
    // 서버의 디비에서 리스토어해서 앱의 sqlite에 갱신
    func restoreInDataBase(sourceDictArray:[NSDictionary]){
        let dbmgr = dbMgr()
        dbmgr.resetDiary()
        
        for outab in sourceDictArray{
            let tempObject = DiaryObject()
            
            let content = outab["content"]
            //tempObject.Content = NSData(base64EncodedString: String(content!), options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters) // Base64 String을  Decoding하여 NSData 로 변환함///될지안될지모름 일단
            tempObject.Content = NSData(base64EncodedString: String(content!), options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            let date = outab["date"]
            tempObject.Date = String(date!)
            let subject = outab["subject"]
            tempObject.Subject = String(subject!)
            let weather = outab["weather"]
            tempObject.Weather = weather?.integerValue
            let face = outab["face"]
            tempObject.Face = face?.integerValue
            dbmgr.updateDiaryData(tempObject)
        }
        
    }
}
