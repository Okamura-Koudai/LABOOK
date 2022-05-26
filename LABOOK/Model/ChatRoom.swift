//
//  Chat.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/04/01.
//

import Foundation
import Firebase

class ChatRoom{
    
    let partnerEmail: String
    let createAt: Timestamp
    let chatBackgroundImage: String
    let chatFont: String
    let chatFontSize: String
    let shareMemoContent: String
    
    init(dic: [String: Any]){
        self.partnerEmail = dic["partnerEmail"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.chatBackgroundImage = dic["chatBackgroundImage"] as? String ?? ""
        self.chatFont = dic["chatFont"] as? String ?? ""
        self.chatFontSize = dic["chatFontSize"] as? String ?? ""
        self.shareMemoContent = dic["shareMemoContent"] as? String ?? ""
    }
}
