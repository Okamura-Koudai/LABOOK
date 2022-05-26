//
//  FirstTutorialViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/05/05.
//

import UIKit
import Firebase
import Nuke

class FirstTutorialViewController: UIViewController {
    
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var toTutorialButton: UIButton!
    @IBOutlet weak var successMessageTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPairsInfo()
        partnerImageView.layer.cornerRadius = 50
        myImageView.layer.cornerRadius = 50
        heartImageView.layer.cornerRadius = 25
        toTutorialButton.layer.cornerRadius = 20
        
    }
    
    
    @IBAction func toTutorialButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "SecondTutorialViewController") as! SecondTutorialViewController
        self.present(nextView, animated: true, completion: nil)
    }
    
    func fetchPairsInfo(){
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
            Nuke.loadImage(with: url, into: self.myImageView)
            
            Firestore.firestore().collection("users").document(partnerEmail).getDocument {(snapshot, err ) in
                if let err = err{
                    print("パートナーユーザー情報の取得に失敗しました。\(err)")
                    return
                }
                let dic = snapshot?.data()
                let partner = Partner.init(dic: dic!)
                let url = URL(string: partner.profileImageUrl)!
                Nuke.loadImage(with: url, into: self.partnerImageView)
                let partnerName = partner.username
                self.successMessageTextView.text = "おめでとうございます！\n\(partnerName)さんとのリンクに成功しました！"
            }
        }
    }

}
