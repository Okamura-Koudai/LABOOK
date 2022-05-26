//
//  LoginViewController.swift
//  lovenote
//
//  Created by Koudai Okamura on 2022/01/28.
//

import UIKit
import Firebase
import FirebaseFirestore
import Network
import PKHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var userEmail :String!
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.sample") //インターネット接続確認用
    @IBOutlet weak var LoginEmailTextField: UITextField!
    @IBOutlet weak var LoginPasswordTextField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var switchSecureTextEntryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = Auth.auth().currentUser?.email {
            LoginEmailTextField.text = email
        }
        LoginEmailTextField.delegate = self
        LoginPasswordTextField.delegate = self
        LoginButton.isEnabled = false
        LoginButton.backgroundColor = UIColor.gray
        LoginButton.setTitleColor(UIColor.white, for: .normal)
        connectionConfirmation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    //以下3つ、キーボードに合わせてViewを動かす
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 170
        }
    }
    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = LoginEmailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = LoginPasswordTextField.text?.isEmpty ?? false
        if emailIsEmpty || passwordIsEmpty {
            LoginButton.isEnabled = false
            LoginButton.backgroundColor = UIColor.gray
            LoginButton.setTitleColor(UIColor.white, for: .normal)
        }else{
            LoginButton.isEnabled = true
            LoginButton.backgroundColor = UIColor.white
            LoginButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    @IBAction func switchSecureTextEntryButton(_ sender: Any) {
        if LoginPasswordTextField.isSecureTextEntry == true{
            LoginPasswordTextField.isSecureTextEntry.toggle()
            let falsePicture = UIImage(systemName: "eye.circle.fill")!
            switchSecureTextEntryButton.setImage(falsePicture, for: .normal)
            
        }else {
            LoginPasswordTextField.isSecureTextEntry.toggle()
            let truePicture = UIImage(systemName: "eye.slash.circle.fill")!
            switchSecureTextEntryButton.setImage(truePicture, for: .normal)
        }
    }
    
    @IBAction func LoginButton(_ sender: Any) {
        
        guard let myEmail = LoginEmailTextField.text else { return }
        guard let password = LoginPasswordTextField.text else { return }
        
            HUD.show(.progress)
            Auth.auth().signIn(withEmail: myEmail, password: password) { (res, err) in
                if let err = err {
                    print("ログインに失敗しました。\(err)")
                    self.LoginButton.isEnabled = false
                    self.LoginButton.backgroundColor = UIColor.gray
                    //アラート表示
                    let alert = UIAlertController(title: "ログイン失敗", message: "Emailとパスワードをご確認ください。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                    HUD.hide()
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                Firestore.firestore().collection("users").document(myEmail).getDocument {(snapshot, err ) in
                    if let err = err{
                        print("ログインユーザーの取得に失敗しました。\(err)")
                        return
                    }
                    let dic = snapshot?.data()
                    let user = User.init(dic: dic!)
                    let myPartnerEmail = user.email
                    if myPartnerEmail != ""{
                        //自分のpartnerEmailが持つpartnerEmailが自分のEmailか判定
                        Firestore.firestore().collection("users").document(myPartnerEmail).getDocument {(snapshot, err ) in
                            if let err = err{
                                print("パートナーユーザーの取得に失敗しました。\(err)")
                                return
                            }
                            if (snapshot?.data()) != nil{
                                let dic = snapshot?.data()
                                let partner = Partner.init(dic: dic!)
                                let partnerEmailOfPartner = partner.email
                                
                                //①入力した相手のパートナーUIDに自分のUIDが入っている場合→リンク完了
                                if partnerEmailOfPartner == myEmail{
                                    print("①入力した相手のパートナーUIDに自分のUIDが入っている場合→リンク完了")
                                    let storyboard: UIStoryboard = self.storyboard!
                                    let vc = storyboard.instantiateViewController(withIdentifier: "tabBarController")
                                    self.present(vc,animated: true)
                                    
                                //②入力した相手のパートナーUIDに自分のUIDが入っていない場合→待機画面へ
                                }else{
                                    print("入力した相手のパートナーUIDに自分のUIDが入っている場合→リンク完了")
                                    let storyboard: UIStoryboard = self.storyboard!
                                    let vc = storyboard.instantiateViewController(withIdentifier: "WaittingLinkViewController") as! WaittingLinkViewController
                                    vc.partnerEmail = partnerEmailOfPartner
                                    HUD.hide()
                                    self.present(vc,animated: true)
                                }
                            }
                        }
                        
                    //③partnerEmailniが空であればリンク画面へ
                    }else if myPartnerEmail.count == 0 {
                        print("③partnerEmailが空欄であればリンク画面へ")
                        print("myPartnerEmail.count",myPartnerEmail.count)
                        let storyboard: UIStoryboard = self.storyboard!
                        let VC = storyboard.instantiateViewController(withIdentifier: "LinkPartner")
                        HUD.hide()
                        self.present(VC, animated: true)
                    }
                }
            }
    }
    
    func  connectionConfirmation(){
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                print("インターネットに接続されていません。")
                let alert = UIAlertController(title: "エラー", message: "インターネット接続がオフラインのようです。", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "もう一度試す", style: .cancel) { action in
                }
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        monitor.start(queue: queue)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // リターンキーでキーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}


//埋もれている　キーボード
