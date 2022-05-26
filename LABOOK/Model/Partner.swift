//
//  User.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/02/07.
//

import Foundation
import Firebase

class Partner{
    let email: String
    let username: String
    let createAt: Timestamp
    let profileImageUrl: String
    let UserID: String
    let partnerEmail: String
    let chatRoomDocId: String
    
    init(dic: [String: Any]){
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.UserID = dic["UserID"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.partnerEmail = dic["partnerEmail"] as? String ?? ""
        self.chatRoomDocId = dic["chatRoom"] as? String ?? ""

    }
}

