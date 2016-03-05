//
//  WriteDiaryInfo.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 10..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import Foundation


    // CVCalendar에서 생성한 날짜를 앱에 맞게 가지고 있기 위한 자료형
class WriteDiaryInfo{
    var thisYear:String = "" // 년
    var thisMonth:String = ""  // 월
    var thisDay:String = ""  // 일
    
    init(year: String, month: String, day: String){
        thisYear = year
        thisMonth = month
        thisDay = day
    }

    
    
}