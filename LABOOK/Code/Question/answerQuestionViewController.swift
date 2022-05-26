//
//  answerQuestionViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/04/24.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD

class answerQuestionViewController: UIViewController, UITextFieldDelegate {
    
    var myCurrentAnswer:String!
    var questionName:String!
    var questionSubject:String!
    var transitionSource:String!
    
    @IBOutlet weak var answerQuestionTextField: UITextField!
    @IBOutlet weak var countCharactersLabel: UILabel!
    @IBOutlet weak var overCharactersLavel: UILabel!
    @IBOutlet weak var answerSaveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerSaveButton.layer.cornerRadius = 10
        self.title = questionSubject
        answerQuestionTextField.delegate = self
        if myCurrentAnswer == "読み込み中"{
            myCurrentAnswer = "未回答"
        }
        answerQuestionTextField.placeholder = myCurrentAnswer
        answerQuestionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if answerQuestionTextField.text != nil{
            answerSaveButton.isEnabled = true
        }
        
    }
    
    func sendNotice(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument { (snapshot, err ) in
            if let err = err{
                print("ノート情報の取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let user = User.init(dic: dic!)
            let userName = user.username
            let userImage = user.profileImageUrl
            let partnerEmail = user.partnerEmail
            
                let docData = [
                    "createAt": Timestamp(),
                    "email": partnerEmail,
                    "userName": userName,
                    "transitionSource": self.transitionSource!,
                    "noticeMessage": "質問に回答しました！",
                    "noticeImageView": userImage,
                    "pageSubject": "",
                    "changeSettingTextToRed": true
                ] as [String : Any]
                
                Firestore.firestore().collection("users").document(partnerEmail).collection("notices").document().setData(docData){ err in
                    if let err = err{
                        print("noticeの保存に失敗しました。\(err)")
                    }else{
                    
                }
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let charactersCount = answerQuestionTextField.text?.count ?? 0
        countCharactersLabel.text = "\(String(describing: charactersCount))/20"
        if charactersCount > 20 || charactersCount == 0 {
            overCharactersLavel.isHidden = false
            answerSaveButton.isEnabled = false
        }else{
            overCharactersLavel.isHidden = true
            answerSaveButton.isEnabled = true
        }
      }
    
    @IBAction func answerSaveButton(_ sender: Any) {
        HUD.show(.progress)
        guard let newQuestionAnswer =
                answerQuestionTextField.text else {return}
        let docData = [
            "answer" : newQuestionAnswer,
        ] as [String : Any]
        
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("question").document(email).collection(questionName).document(questionSubject).setData(docData) { err in
            if let err = err {
                print("回答の保存に失敗しました。：\(err)")
            } else {
                self.sendNotice()
                HUD.hide()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // リターンキーでキーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
}
