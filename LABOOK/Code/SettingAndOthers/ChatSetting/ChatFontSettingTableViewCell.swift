//
//  ChatSettingTableViewCell.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/04/03.
//

import UIKit
import Firebase
import Nuke
import FirebaseStorage
import FirebaseFirestore

class ChatFontSettingTableViewCell: UITableViewCell{
    
    @IBOutlet weak var partnerMessageImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var myMessageImageView: UIImageView!
//    @IBOutlet weak var partnerMessageTextWidthConstraint: NSLayoutConstraint!
//    @IBOutlet weak var myMessageTextWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        partnerMessageImageView.layer.cornerRadius = 25
        myMessageImageView.layer.cornerRadius = 25
        partnerMessageTextView.layer.cornerRadius = 15
        myMessageTextView.layer.cornerRadius = 15
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
    }
    
    func fetchUsersImage(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let User = User.init(dic: dic!)
            let partnerEmail = User.partnerEmail
            let url = URL(string: User.profileImageUrl)!
            Nuke.loadImage(with: url, into: self.myMessageImageView)
            
            Firestore.firestore().collection("users").document(partnerEmail).getDocument {(snapshot, err ) in
                if let err = err{
                    print("パートナーユーザー情報の取得に失敗しました。\(err)")
                    return
                }
                let dic = snapshot?.data()
                let Partner = Partner.init(dic: dic!)
                let url = URL(string: Partner.profileImageUrl)!
                Nuke.loadImage(with: url, into: self.partnerMessageImageView)
            }
        }
    }
    
    
}
