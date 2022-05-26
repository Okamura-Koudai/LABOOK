//
//  SixthTutorialViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/05/05.
//

import UIKit
import Firebase

class SecondTutorialViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var toStartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toStartButton.layer.cornerRadius = 15
    }
    
    @IBAction func toStartButton(_ sender: Any) {
        guard let email = Auth.auth().currentUser?.email else {return}
        let docData = [
            "createAt": Timestamp(),
            "email": email,
            "userName": "LABOOK",
            "transitionSource": "",
            "noticeMessage": "情報の更新はこの画面をご確認ください。",
            "noticeImageView": "C47882BF-DF3B-4EA7-8214-B2C1BB1587FA",
            "pageSubject": "",
            "changeSettingTextToRed": true
        ] as [String : Any]
        
        Firestore.firestore().collection("users").document(email).collection("notices").document().setData(docData){ err in
            if let err = err{
                print("noticeの保存に失敗しました。\(err)")
            }else{
                let storyboard: UIStoryboard = self.storyboard!
                let vc = storyboard.instantiateViewController(withIdentifier: "tabBarController")
                self.present(vc,animated: true)
                // プッシュ通知の許可を依頼する際のコード
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                    
                    if granted {
                        UNUserNotificationCenter.current().delegate = self
                    } 
                }
            }
        }
    }

}
