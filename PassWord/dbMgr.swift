//
//  dbMgr.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 9..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import Foundation
import SQLite

// 파일입출력으로 비밀번호를 저장하면 어떨까.... 
// 사용자 고유의 어떠한 값을 이용한 해쉬함수도 같이 이용해보면 어떨지.. -> 꿈

class dbMgr {
    
    var db: Connection?
    
    init(){
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        do{  db = try Connection("\(path)/db.sqlite3")

        }catch{  print("DB Connection Error!\n")  }
        
        // 디비 객체가 생성될때 변화를 감지하고 동적으로 테이블을 생성
        if(db?.totalChanges == 0){
            self.create_Diarytable()
            self.create_UserIdTable()
        }
    }
    
    deinit{
        
    }
    
    
    // 유저의 개인정보를 가지고 있는 테이블 - Column이 1개만 존재 - ID가 PK로 지정됨
    func create_UserIdTable(){
        do{
            try db?.execute("CREATE TABLE Myinfo (" +
                "id TEXT PRIMARY KEY, " +
                "password TEXT, " +
                "mail TEXT, " +
                "loginauth INTEGER)")
        }
        catch{
            //print("Create Myinfo Table Error")
        }
    }
    
    // 다이어리의 테이블 - 날짜/제목/내용/날씨/기분의 정보를 가지고 있다. 날짜가 PK가 된다.
    // 앱 로직상 같은날짜의 두개의 객체를 생성해내지 않는다.  (유니크속성은 지정안했음)
    func create_Diarytable(){
        do{
            try db?.execute("CREATE TABLE Diary (" +
                "date TEXT PRIMARY KEY, " +
                "subject TEXT, " +
                "content BLOB, " + //
                "weather INTEGER, " +
                "face INTEGER)" )
        }
        catch{
           // print("Create Diary error")
        }
    }
    
    
    // 유저인포 테이블을 생성합니다 - /아이디/패스워드/메일/로그인여부의 attribute를 가집니다
    func initMyinfoTable(){
        do{
            try db?.run("INSERT INTO Myinfo (id, password, mail, loginauth) values (?,?,?,?)", "tempuser", "0000", "",0)
        }
        catch{
            print("init myinfo Table Error")
        }
    }
    
    
    // 유저인포의 비밀번호를 리턴합니다. - PassSignView에서의 체크용도
    func checkPassword()->String?{
        var returnPassword:String?
        let table = Table("Myinfo")
        let password = Expression<String>("password")
        for ID in db!.prepare(table){
            returnPassword = ID[password]
        }
        return returnPassword
    }
    
    // 현재 유저의 정보를 디비에서 통째로 꺼내는 메소드
    func getMyInfo()->IdentificationInfo{
        let returnInfo:IdentificationInfo! = IdentificationInfo()
        let table = Table("Myinfo")
        let id = Expression<String>("id")
        let password = Expression<String>("password")
        let mail = Expression<String>("mail")
        let loginauth = Expression<Int64>("loginauth")
        
        for Info in db!.prepare(table){
            returnInfo.setID(Info[id])
            returnInfo.setPassWord(Info[password])
            returnInfo.setMail(Info[mail])
            returnInfo.setLoginFlag(Int(Info[loginauth]))
        }
        return returnInfo
    }
    
    
    // 비밀번호 변경시 - 콜롬을 지우고 새로생성 - Update문
    func updatePassWord(newUserId: IdentificationInfo){
        do{
            try db?.run("DELETE FROM Myinfo WHERE (id = ?)", newUserId.getID())
            try db?.run("INSERT INTO Myinfo (id, password, mail, loginauth) values (?,?,?,?)", newUserId.getID(), newUserId.getPassWord(), newUserId.getMail(), newUserId.getLoginFlag())
        }
        catch{
            print("updatePassword Error")
        }
    }
    

    // 다이어리가 수정된경우 지우고 새로생성합니다.
    func updateDiaryData(data: DiaryObject){
        do{
            try db?.run("DELETE FROM Diary WHERE (date = ?)", data.Date)
            insertDiaryData(data)
        }
        catch{
            print("Update Failed!!")
        }
        
    }
    
    // 새로운 날짜의 일기를 기록하는 경우 DB - insert
    func insertDiaryData(data: DiaryObject){
        do{
            let table = Table("Diary")
            let date = Expression<String>("date")
            let subject = Expression<String>("subject")
            let content = Expression<NSData>("content")
            let weather = Expression<Int64>("weather")
            let face = Expression<Int64>("face")
            
            //let blob = Blob(bytes: data.content.bytes, length: data.content.length)
            let inserting = table.insert(date <- data.Date, subject<-data.Subject, content <- data.Content, weather<-Int64(data.Weather), face<-Int64(data.Face))
            try db?.run(inserting)
        }
        catch{
            print("Insert Error!")
        }
    }
    
    
    // 선택된 날짜의 다이어리를 가져옵니다. (이렇게하지말고 select from diary where date = ?과 같은형태가 가능한가?)
    func select_SelectedDay(selectedDate: String) -> DiaryObject?{
        var TempObject:DiaryObject
        let table = Table("Diary")
        let date = Expression<String>("date")
        let subject = Expression<String>("subject")
        let content = Expression<NSData>("content")
        let weather = Expression<Int64>("weather")
        let face = Expression<Int64>("face")
        
        for diary in db!.prepare(table){
            if diary[date] == selectedDate{
                TempObject = DiaryObject()
                TempObject.Date = diary[date]
                TempObject.Subject = diary[subject]
                TempObject.Content = diary[content]
                TempObject.Weather = Int(diary[weather])
                TempObject.Face = Int(diary[face])
                return TempObject
            }
        }
        return nil
    }
    
    // 전체일기를 통째로 가져오는 메소드 - DiaryObject의 배열을 만들어 리턴
    func select_AllDiary() -> [DiaryObject]{
        var ReturnObjectArray:[DiaryObject] = [DiaryObject]()
        var TempObject:DiaryObject!
        let table = Table("Diary")
        let date = Expression<String>("date")
        let subject = Expression<String>("subject")
        let content = Expression<NSData>("content")
        let weather = Expression<Int64>("weather")
        let face = Expression<Int64>("face")
        // var cnt:Int = 0
        
        for diary in db!.prepare(table){
            TempObject = DiaryObject()
            TempObject.Date = diary[date]
            TempObject.Subject = diary[subject]
            TempObject.Content = diary[content]
            TempObject.Weather = Int(diary[weather])
            TempObject.Face = Int(diary[face])
            ReturnObjectArray.append(TempObject)
        }
        
        ReturnObjectArray.sortInPlace({$0.Date < $1.Date})
        return ReturnObjectArray
    }
    
    func select_AllDate() -> [String]{
    
        var tmpArray:[String] = [String]()
        
        let table = Table("Diary")
        let date = Expression<String>("date")
        
        for db_date in db!.prepare(table){
            tmpArray.append(db_date[date])
        }
        
        return tmpArray
    }
    
    // 해당날짜에 다이어리가 있는지를 검사합니다.
    func isExistDiary(day:String, date_Array: [String])->Bool{
        for date in date_Array{
            if(date == day){
                //print(day)
                return true
            }
        }
        return false
    }
    
    
    
    // 다이어리를 리셋합니다. - 테이블을 날리고 새로생성
    func resetDiary(){
        do{
            try db?.run("DROP TABLE Diary")
            create_Diarytable()
            //print("내용 초기화 완료")
        }
        catch{
            print("resetDiary Error")
        }
    }
    
    // 선택된 날짜의 다이어리를 DB에서 지웁니다.
    func delete(selectedDate: String!) -> Bool{
        do{
            try db?.run("DELETE FROM Diary WHERE (date = ?)", selectedDate)
            return true
        }
        catch{
            print(" \(selectedDate) row Delete Failed")
        }
        return false
    }
    
    

    
}

