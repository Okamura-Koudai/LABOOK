import UIKit
import Firebase
import FirebaseFirestore
import PKHUD

class LinkPartnerViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var MyUserIdTextField: UITextField!
    @IBOutlet weak var partnerIdTextField: UITextField!
    @IBOutlet weak var LinkPartnerButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let email = Auth.auth().currentUser?.email {
            self.MyUserIdTextField.text = email
        }
        partnerIdTextField.delegate = self
        LinkPartnerButton.layer.cornerRadius = 20
        shareButton.layer.cornerRadius = 28
        //        partnerIdTextField.layer.cornerRadius = 50
        //        MyUserIdTextField.layer.cornerRadius = 50
       
    }
    
    @IBAction func LinkPartnerButton(_ sender: Any) {
        if let partnerEmail = partnerIdTextField.text {
            HUD.show(.progress)
            guard let myEmail = Auth.auth().currentUser?.email else {return}
            Firestore.firestore().collection("users").document(myEmail).updateData([
                "partnerEmail": partnerEmail
            ]) { err in
                if let err = err {
                    
                    print("partnerEmailのアップデートに失敗しました。: \(err)")
                    let alert = UIAlertController(title: "リンク申請失敗", message: "入力情報を再度ご確認ください。", preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "戻る", style: .default) { action in
                    }
                    alert.addAction(yesAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else{
                    
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
                            if partnerEmailOfPartner == myEmail {
                                self.createChatRoom()
                                let storyboard: UIStoryboard = self.storyboard!
                                let vc = storyboard.instantiateViewController(withIdentifier: "FirstTutorialViewController")
                                HUD.hide()
                                self.present(vc,animated: true)
                                
                            //入力した相手のパートナーUIDに自分のUIDが入っていない場合→待機画面へ
                            }else{
                                let storyboard: UIStoryboard = self.storyboard!
                                let vc = storyboard.instantiateViewController(withIdentifier: "WaittingLinkViewController") as! WaittingLinkViewController
                                vc.partnerEmail = partnerEmail
                                HUD.hide()
                                self.present(vc,animated: true)
                            }
                        //まだ登録されていないメールアドレスでも遷移
                        }else {
                            let storyboard: UIStoryboard = self.storyboard!
                            let vc = storyboard.instantiateViewController(withIdentifier: "WaittingLinkViewController") as! WaittingLinkViewController
                            vc.partnerEmail = partnerEmail
                            HUD.hide()
                            self.present(vc,animated: true)
                        }
                        
                    }
                }
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
            let chatFont = "AlNile"
            
            let docData = [
                "partnerEmail" : partnerEmail,
                "createdAt" : Timestamp(),
                "chatBackgroundImage": chatBackgroundImage,
                "chatFont": chatFont,
            ] as [String : Any]
            
            Firestore.firestore().collection("chatRoom").document(email).setData(docData) { (err) in
                if let err = err{
                    print("chatRoom情報の保存に失敗しました。\(err)")
                    return
                }
            }
        }
    }
    
    @IBAction func shareButton(_ sender: Any) {
        let text = MyUserIdTextField.text
        let shareText = """
        あなたのパートナーがあなたを「LaBook」に招待しました！以下の3STEPでアプリを始めましょう。
        
        ①「LaBook」をインストール
        アプリのリンク
        ②メールアドレスでユーザー登録
        ③パートナーのメールアドレスを入力
        \(String(describing: text))
        """
        let items = [shareText]
        let activityVC = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}


//パートナーIDを入力しないとボタンを押せないようにする
//ログインからだとスキップされる
//タップした時にコピできるようにしたい
//相手が登録済みでないとエラーアラートが出る
