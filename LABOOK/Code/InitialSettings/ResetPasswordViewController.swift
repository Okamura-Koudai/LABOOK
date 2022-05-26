//
//  ResetPasswordViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/05/15.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newPasswordTextField.delegate = self
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let currentPasswordIsEmpty = newPasswordTextField.text?.isEmpty ?? false
        
        if currentPasswordIsEmpty {
            resetPasswordButton.isEnabled = false
        }else{
            resetPasswordButton.isEnabled = true
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func resetPasswordButton(_ sender: Any) {
        guard let password = newPasswordTextField.text else {return}
        
        Auth.auth().currentUser?.updatePassword(to: password) { error in
            if let error = error {
                print("パスワードのアップデートに失敗しました。\(error)")
                
                let alert = UIAlertController(title: "失敗", message: "パスワード再設定に失敗しました。入力された文字を確認し、再度ボタンを押してください。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "パスワードの変更に成功しました。", message: "変更されたパスワードを忘れないようにしてください！", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.dismiss(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
