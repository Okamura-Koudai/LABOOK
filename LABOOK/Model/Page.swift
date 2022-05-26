//
//  Page.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/28.
//

import Foundation
import Firebase

class Page{
    
    let email: String
    let createAt: Timestamp
    let netxtSuject: String
    let pageContent: String
    let thunailsImageView: String
    let userImageUrl:String
    let pageSubject:String
    let userName: String
    let commentText: String
    
    init(dic: [String: Any]){
        self.email = dic["email"] as? String ?? ""
        self.netxtSuject = dic["netxtSuject"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.pageContent = dic["pageContent"] as? String ?? ""
        self.thunailsImageView = dic["thunailsImageView"] as? String ?? ""
        self.userImageUrl = dic["userImageUrl"] as? String ?? ""
        self.pageSubject = dic["pageSubject"] as? String ?? ""
        self.userName = dic["userName"] as? String ?? ""
        self.commentText = dic["commentText"] as? String ?? ""
    }
}
