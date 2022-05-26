//
//  FirstQuestion.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/04/06.
//

import Foundation
import UIKit
import Firebase

class Question {
   
    let answer: String
    //let questionNumber: String
    //let question: String
    //let questionAnswer: String
    
    init(dic :[String:Any]){
       
        self.answer = dic["answer"] as? String ?? "未回答"
        //        self.question = dic["question"] as? String ?? ""
//        self.questionNumber = dic["questionNumber"] as? String ?? ""
//        self.question = dic["question"] as? String ?? ""
//        self.questionAnswer = dic["questionAnswer"] as? String ?? ""
//
        
    }
}
