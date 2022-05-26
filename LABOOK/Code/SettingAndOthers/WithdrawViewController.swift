//
//  WithdrawViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/02/12.
//

import UIKit
import Firebase

private let cellId = "cellId"
var tappdewithdrawReason = [Int]()

class WithdrawViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var flg = false
    var withdrawReasonsList = [
        "一時的に退会したい",
        "プライバシーについて懸念がある",
        "コンテンツに飽きた",
        "必要性を感じなかった",
        "使いにくかった",
        "恋人と別れた",
        "その他の理由"
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return withdrawReasonsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = withdrawReasonsTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let ReasonLabel = cell.viewWithTag(1) as! UILabel
        ReasonLabel.text = String(describing: withdrawReasonsList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = withdrawReasonsTableView.cellForRow(at:indexPath)
        cell?.accessoryType = .checkmark
        tappdewithdrawReason.append(indexPath.row)
    }
    
    // セルの選択が外れた時に呼び出される
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = withdrawReasonsTableView.cellForRow(at:indexPath)
        cell?.accessoryType = .none
        if tappdewithdrawReason.contains(indexPath.row){
            tappdewithdrawReason.removeAll(where: { $0 ==  indexPath.row})
            
        }
    }
    
    
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var withdrawReasonTextView: PlaceTextView!
    @IBOutlet weak var withdrawReasonsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        withdrawButton.layer.cornerRadius = 20
        withdrawReasonTextView.placeHolder = "改善点や不満な点があればお聞かせください。"
        withdrawReasonTextView.delegate = self
        withdrawReasonsTableView.delegate = self
        withdrawReasonsTableView.dataSource = self
        withdrawReasonsTableView.allowsMultipleSelection = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    //以下3つ、キーボードに合わせてViewを動かす
    @objc func keyboardWillShow(notification: NSNotification) {
//            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= 300
                }
            }
        //}
        
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
    
    
    @IBAction func withdrawButton(_ sender: Any) {
        let alert = UIAlertController(title: "本当に削除しますか？", message: "この操作は取り消せません。", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "アカウント削除", style: .default) { action in
            //削除理由
            guard let withdrawReasonTextView = self.withdrawReasonTextView.text else {return}
            
            let docData = [
                "withdrawReasonTextView": withdrawReasonTextView,
                "tappdewithdrawReasonButton" : tappdewithdrawReason
            ] as [String : Any]
            //削除理由
            if self.withdrawReasonTextView.text != nil {
                Firestore.firestore().collection("withdraw").document().setData(docData){ (err) in
                    if let err = err {
                        print("退会理由の保存に失敗しました。\(err)")
                        return
                    }
                    print("退会理由の保存に成功しました。")
                }
            }
            self.deleteUserData()
            self.deleteNoteData()
            self.deleteQuestionData()
            self.deleteChatRoomData()
            
            //アカウント削除
            let user = Auth.auth().currentUser
            user!.delete() { error in
                if let error = error {
                    print("ログインユーザーの削除に失敗しました。\(error)")
                    return
                } else {
                    print("ログインユーザーの削除に成功しました。")
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action in }
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteUserData(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).delete(){ error in
            if let error = error {
                print("ユーザーの削除に失敗しました。\(error)")
                return
            }
        }
    }
    
    func deleteNoteData(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("note").document(email).delete(){ error in
            if let error = error {
                print("ユーザーノートの削除に失敗しました。\(error)")
                return
            }
        }
    }
    
    func deleteQuestionData(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("question").document(email).delete(){ error in
            if let error = error {
                print("ユーザークエスチョンの削除に失敗しました。\(error)")
                return
            }
        }
    }
    
    func deleteChatRoomData(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("chatRoom").document(email).delete(){ error in
            if let error = error {
                print("ユーザーチャットの削除に失敗しました。\(error)")
                return
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
