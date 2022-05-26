//
//  Message.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/20.
//

import Foundation
import UIKit
import Firebase
//スペル注意

class Message {
    let message: String
    let email: String
    let createAt: Timestamp
    let profileImageUrl: String
    
    init(dic :[String:Any]){
        self.message = dic["message"] as? String ?? ""
        self.email = dic["email"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        
    }
    
}
