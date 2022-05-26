//
//  DatingDateViewController.swift
//  lovenote
//
//  Created by Koudai Okamura on 2022/01/29.
//

import UIKit
import Firebase
import PKHUD

class DatingDateViewController: UIViewController, UITextFieldDelegate {
    
    let datePicker:UIDatePicker = UIDatePicker()
    var dismissButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var DatingDateInputTextView: UITextField!
    @IBOutlet weak var dateInputPickerView: UIDatePicker!
    @IBOutlet weak var CalResultLabel: UILabel!
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        
        fetchInitialValue()
        dismissButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissButtonPressed(_:)))
        dismissButtonItem.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = dismissButtonItem

    }
    
    
    @IBAction func DatingDateInputPicker(_ sender: Any) {//Pickerの値が変更された時に呼び出されるメソット(value changed)
        let dayInterval = ((Calendar.current.dateComponents([.day], from: dateInputPickerView.date , to: Date())).day!) + 1
        if dayInterval > 0 {
            
            CalResultLabel.text = "→お付き合い開始より\(String(describing: dayInterval))日"
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy年MM月dd日"
                    DatingDateInputTextView.text = formatter.string(from: (sender as AnyObject).date)
            
            guard let email = Auth.auth().currentUser?.email else {return}
            Firestore.firestore().collection("users").document(email).updateData([
                "startDatingDate": dateInputPickerView.date
            ]) { err in
                if let err = err {
                    print("交際のアップデートに失敗しました。: \(err)")
                }else{
                    HUD.flash(.success, delay: 1.0)
                }
            }
                   
        }else{
            let alert = UIAlertController(title: "未来の日付は入力できません！", message: "本日以前の日付をご入力ください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
    }
    
    @objc func dismissButtonPressed (_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchInitialValue(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument { (snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let user = User.init(dic: dic!)
            let startDatingDate = user.startDatingDate
            let dayInterval = ((Calendar.current.dateComponents([.day], from: startDatingDate , to: Date())).day!) + 1
            self.CalResultLabel.text = "→お付き合い開始より\(String(describing: dayInterval))日"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            self.DatingDateInputTextView.text = formatter.string(from: startDatingDate)
        }
    }

    
}
