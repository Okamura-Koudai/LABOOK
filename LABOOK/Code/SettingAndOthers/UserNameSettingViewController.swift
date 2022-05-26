//
//  UserNameSettingViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/05/02.
//

import UIKit
import Firebase
import PKHUD

class UserNameSettingViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var currentUserNameTextField: UITextField!
    @IBOutlet weak var newUserNameTexField: UITextField!
    @IBOutlet weak var userNameSaveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newUserNameTexField.delegate = self
        userNameSaveButton.layer.cornerRadius = 15
        fetchCurrentUserName()
        
    }
    
    func fetchCurrentUserName(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument { (snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let User = User.init(dic: dic!)
            self.currentUserNameTextField.text = User.username
            
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let currentNameIsEmpty = currentUserNameTextField.text?.isEmpty ?? false
        let newNameIsEmpty = newUserNameTexField.text?.isEmpty ?? false
        
        if currentNameIsEmpty || newNameIsEmpty {
            userNameSaveButton.isEnabled = false
        }else{
            userNameSaveButton.isEnabled = true
        }
        
    }
    
    @IBAction func userNameSaveButton(_ sender: Any) {
        newUserNameTexField.resignFirstResponder()
        guard let newUserName = newUserNameTexField.text else {return}
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).updateData([
            "username": newUserName
        ]) { err in
            if let err = err {
                print("userNameのアップデートに失敗しました。: \(err)")
                return
            } else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    HUD.flash(.success, delay: 1.0)
                }
                self.currentUserNameTextField.text = newUserName
                self.newUserNameTexField.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // リターンキーでキーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
}
