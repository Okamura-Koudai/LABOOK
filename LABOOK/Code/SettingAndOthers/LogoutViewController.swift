//
//  LogoutViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/02/19.
//

import UIKit
import Firebase
import FirebaseAuth
import PKHUD

class LogoutViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var updatePasswordButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        updatePasswordButton.layer.cornerRadius = 20
        logoutButton.layer.cornerRadius = 20
        currentPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
    }
    

    func textFieldDidChangeSelection(_ textField: UITextField) {

        let currentPasswordlIsEmpty = currentPasswordTextField.text?.isEmpty ?? false
        let newPasswordIsEmpty = newPasswordTextField.text?.isEmpty ?? false

        if currentPasswordlIsEmpty || newPasswordIsEmpty {
            updatePasswordButton.isEnabled = false
        }else{
            updatePasswordButton.isEnabled = true
        }

    }

    
    @IBAction func updatePasswordButton(_ sender: Any) {
//        guard let currentPassword = currentPasswordTextField.text else { return }
//        guard let newpassword = newPasswordTextField.text else { return }
//        guard let comfirmPassword = comfirmPasswordTextField.text else { return }
//
//        guard let email = Auth.auth().currentUser?.email else {return}
//        Firestore.firestore().collection("users").document(email).getDocument {(snapshot, err ) in
//            if let err = err{
//                print("ログインユーザーの取得に失敗しました。\(err)")
//                return
//            }
//        }
//
//        if currentPassword == password && newpassword == comfirmPassword {
//
//
//        Auth.auth().currentUser?.updatePassword(to: password) { error in
//            if let err = err {
//                print("パスワードの変更に失敗しました。\(err)")
//                return
//            }
//        }else
//            print(111111)
//        //再度入力した項目の誤りがあります。のアラート
//            }
    }
    
    
    @IBAction func logoutButton(_ sender: Any) {
        let alert = UIAlertController(title: "ログアウトしますか？", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "ログアウトする", style: .default) { action in
            HUD.show(.progress)
            do {
                try Auth.auth().signOut()
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                print("ログアウトに成功しました。")
                HUD.hide()
            }catch{
                print("ログアウトに失敗しました。\(error)")
                HUD.hide()
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action in }
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
