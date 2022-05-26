//
//  forgetPasswordViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/04/30.
//

import UIKit
import Firebase

class forgetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputEmailTextField: UITextField!
    @IBOutlet weak var sendResettingPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputEmailTextField.delegate = self
        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let currentEmailIsEmpty =
            inputEmailTextField.text?.isEmpty ?? false
        
        if currentEmailIsEmpty {
            sendResettingPasswordButton.isEnabled = false
        }else{
            sendResettingPasswordButton.isEnabled = true
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // リターンキーでキーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func sendResettingPasswordButton(_ sender: Any) {
        
        //メール送信
        guard let email = inputEmailTextField.text else {return}
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                //アラート表示
                let alert = UIAlertController(title: "メール送信完了", message: "パスワード再設定用のURLを送りました。タップして、新しいパスワードをご入力ください。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                // 送信完了画面へ
                let storyboard: UIStoryboard = self.storyboard!
                let VC = storyboard.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
                self.navigationController?.pushViewController(VC, animated: true)
                
            }
            //self.showErrorIfNeeded(error)
            //アラート表示
            let alert = UIAlertController(title: "失敗", message: "入力されたパスワードをご確認ください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "戻る", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    //password再設定画面に遷移
    
    
}


//新規登録の段階では認証はいらないけど、パスワード再設定の時には認証を送ればいい
