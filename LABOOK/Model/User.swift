//
//  User.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/02/07.
//

import Foundation
import Firebase

class User{
    
    let email: String
    let username: String
    let createAt: Timestamp
    let profileImageUrl: String
    let UserID: String
    let partnerEmail: String
    let noteFontSize: String
    let noteTextSpacingSize: String
    let noteFont: String
    let startDatingDate: Date
    
    init(dic: [String: Any]){
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.UserID = dic["UserID"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.partnerEmail = dic["partnerEmail"] as? String ?? ""
        self.noteFontSize = dic["noteFontSize"] as? String ?? ""
        self.noteTextSpacingSize = dic["noteTextSpacingSize"] as? String ?? ""
        self.noteFont = dic["noteFont"] as? String ?? ""
        self.startDatingDate = dic["noteFont"] as? Date ?? Date()

    }
}
