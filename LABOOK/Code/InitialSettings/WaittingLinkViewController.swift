//
//  WaittingLinkViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/05/01.
//

import UIKit
import FirebaseStorage
import Firebase
import PKHUD

class WaittingLinkViewController: UIViewController {
    
    var partnerEmail: String!
    @IBOutlet weak var waittingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var backToLinkButton: UIButton!
    @IBOutlet weak var partnerEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partnerEmailLabel.text = partnerEmail!
        reloadButton.layer.cornerRadius = 20
        backToLinkButton.layer.cornerRadius = 20
        waittingIndicatorView.startAnimating()
        
    }
    
    @IBAction func reloadButton(_ sender: Any) {
        guard let myEmail = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(partnerEmail).getDocument {(snapshot, err ) in
            if let err = err{
                print("パートナーユーザーの取得に失敗しました。\(err)")
                return
            }
            
            if (snapshot?.data()) != nil{
                let dic = snapshot?.data()
                let partner = Partner.init(dic: dic!)
                let partnerEmailOfPartner = partner.partnerEmail
                //入力した相手のパートナーUIDに自分のUIDが入っている場合→リンク完了
                if partnerEmailOfPartner == myEmail{
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        HUD.flash(.success, delay: 1.0)
                    }
                    //待機画面へ飛んだユーザーもコンテンツに遷移する前にcreateChatRoom（）
                    self.createChatRoom()
                    let storyboard: UIStoryboard = self.storyboard!
                    let vc = storyboard.instantiateViewController(withIdentifier: "FirstTutorialViewController")
                    self.present(vc,animated: true)
                    
                }else{
                    let alert = UIAlertController(title: "リンク失敗", message: "まだパートナーはおなたのIDを入力していません。もしくは入力された情報が間違っている可能性があります。", preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "OK", style: .default) { action in
                    }
                    alert.addAction(yesAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }else{
                let alert = UIAlertController(title: "エラー", message: "入力された情報が間違っている可能性があります。", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "OK", style: .default) { action in
                }
                alert.addAction(yesAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func createChatRoom(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let User = User.init(dic: dic!)
            let partnerEmail = User.partnerEmail
            let chatBackgroundImage = "color9"
            let chatFontSize = "16"
            let chatFont = "AlNile"
            
            let docData = [
                "partnerEmail": partnerEmail,
                "createdAt" : Timestamp(),
                "chatBackgroundImage": chatBackgroundImage,
                "chatFont": chatFont,
                "chatFontSize": chatFontSize,
            ] as [String : Any]
            
            Firestore.firestore().collection("chatRoom").document(email).setData(docData) { (err) in
                if let err = err{
                    print("chatRoom情報の保存に失敗しました。\(err)")
                    return
                }
            }
        }
    } //なんか二度手間なことしているかも
    
    @IBAction func backToLinkButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
}
