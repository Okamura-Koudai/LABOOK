import Foundation
import UIKit
import Firebase

class Survey {
   
    let email: String
    let answerNumber: String

    init(dic :[String:Any]){
       
        self.email = dic["email"] as? String ?? ""
        self.answerNumber = dic["answerNumber"] as? String ?? "1"
    }
}
