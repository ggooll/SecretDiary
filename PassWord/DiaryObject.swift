//
//  DiaryObject.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 15..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import Foundation

// 다이어리 객체
class DiaryObject{
    
    var Date:String!
    var Subject:String!
    var Content:NSData!   // 이미지와 텍스트가 혼합된 NSAttributedString형을 변환하기위해...
    var Weather:Int!
    var Face:Int!
    
    init(){
        Date = ""
        Subject = ""
        Content = NSData()
        Weather = 0
        Face = 0
    }
    
    init(date:String, subject:String, content: NSData, weather: Int, face:Int){
        self.Date = date
        self.Subject = subject
        self.Content = content
        self.Weather = weather
        self.Face = face
    }
    
    
    // 테스트용 Print
    func Print(){
        print(self.Date!)
        print(self.Subject!)
        print(self.Content!)
        print(self.Weather!)
        print(self.Face!)
    }
    
    
}