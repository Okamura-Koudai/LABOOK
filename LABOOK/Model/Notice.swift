//
//  Notice.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/05/10.
//

import Foundation
import Firebase

class Notice{
    
    let email: String
    let createAt: Timestamp
    let userName: String
    let noticeMessage: String
    let noticeImageView: String
    let transitionSource:String
    let changeSettingTextToRed: Bool
    let pageSubject:String
    
    init(dic: [String: Any]){
        self.email = dic["email"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.userName = dic["userName"] as? String ?? ""
        self.noticeMessage = dic["noticeMessage"] as? String ?? ""
        self.noticeImageView = dic["noticeImageView"] as? String ?? ""
        self.transitionSource = dic["transitionSource"] as? String ?? ""
        self.changeSettingTextToRed = dic["changeSettingTextToRed"] as? Bool ?? false
        self.pageSubject = dic["pageSubject"] as? String ?? ""

    }
}
