//
//  IdentificationIinfo.swift
//  PassWord
//
//  Created by 규철 임 on 2015. 11. 14..
//  Copyright © 2015년 규철 임. All rights reserved.
//

import Foundation


// 유저 인포 - 클래스
class IdentificationInfo{
    private var LoginFlag:Int?
    private var Id:String?
    private var PassWord:String?
    private var Mail:String?
    
    // 이니셜
    init(){
        self.LoginFlag = 0
        self.Id = ""
        self.PassWord = ""
        self.Mail = ""
    }
    
    // get method
    func getPassWord() -> String{
        return PassWord!
    }
    func getLoginFlag() -> Int{
        return LoginFlag!
    }
    func getID() -> String{
        return Id!
    }
    func getMail() -> String{
        return Mail!
    }
    
    
    // set method
    func setMail(input: String){
        self.Mail = input
    }
    func setLoginFlag(input: Int){
        self.LoginFlag = input
    }
    func setPassWord(input: String){
        self.PassWord = input
    }
    func setID(input: String){
        self.Id = input
    }
    
    
}