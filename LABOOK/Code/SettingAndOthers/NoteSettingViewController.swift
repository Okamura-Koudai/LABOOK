//
//  NoteSettingViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/31.
//

import UIKit
import Firebase
import FirebaseFirestore

class NoteSettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    let fontList = [
        "AlNile",
        "AcademyEngravedLetPlain",
        "AlNile-Bold",
        "AmericanTypewriter",
        "AmericanTypewriter-Light",
        "AmericanTypewriter-Semibold",
        "AmericanTypewriter-Bold",
        "AmericanTypewriter-Condensed",
        "AmericanTypewriter-CondensedLight",
        "AmericanTypewriter-CondensedBold",
//        AppleColorEmoji
//        AppleSDGothicNeo-Regular
//        AppleSDGothicNeo-Thin
//        AppleSDGothicNeo-UltraLight
//        AppleSDGothicNeo-Light
//        AppleSDGothicNeo-Medium
//        AppleSDGothicNeo-SemiBold
//        AppleSDGothicNeo-Bold
//        AppleSymbols
//        ArialMT
    ]//もう少し多様なフォントを用紙したい
    
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var textSpacingSizeSlider: UISlider!
    @IBOutlet weak var fontSelectPicker: UIPickerView!
    @IBOutlet weak var PreViewTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fontSelectPicker.delegate = self
        fontSelectPicker.dataSource = self
        fetchNoteFontData()
    }
    
    
    
    @IBAction func fontSizeSlider(_ sender: Any) {
        print("文字サイズスライダーの値：,\(fontSizeSlider.value)")
        let KernAttr = [NSAttributedString.Key.kern: textSpacingSizeSlider.value]
        PreViewTextView.attributedText = NSMutableAttributedString(string: PreViewTextView.text!, attributes: KernAttr)
        PreViewTextView.font = UIFont.systemFont(ofSize: CGFloat(fontSizeSlider.value))
        //Firebaseにアップデート
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("user").document(email).updateData([
            "fontSize": "\(fontSizeSlider.value)"
        ]) { err in
            if let err = err {
                print("fontSizeのアップデートに失敗しました。: \(err)")
            } else {
                print("fontSizeのアップデートに成功しました。")
            }
        }
        
        
    }
    
    @IBAction func textSpacingSizeSlider(_ sender: Any) {
        let KernAttr = [NSAttributedString.Key.kern: textSpacingSizeSlider.value]
        PreViewTextView.attributedText = NSMutableAttributedString(string: PreViewTextView.text!, attributes: KernAttr)
        PreViewTextView.font = UIFont.systemFont(ofSize: CGFloat(fontSizeSlider.value))
        //Firebaseにアップデート
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).updateData([
            "textSpacingSize": "\(textSpacingSizeSlider.value)"
        ]) { err in
            if let err = err {
                print("textSpacingSizeのアップデートに失敗しました。: \(err)")
            } else {
                print("textSpacingSizeのアップデートに成功しました。")
            }
        }
    }
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontList.count
    }
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return fontList[row]
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        PreViewTextView.font = UIFont(name: fontList[row], size: CGFloat(fontSizeSlider.value))
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).updateData([
            "font": fontList[row]
        ]) { err in
            if let err = err {
                print("fontのアップデートに失敗しました。: \(err)")
            } else {
                print("fontのアップデートに成功しました。")
            }
        }
    }
    
    func fetchNoteFontData(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument { [self](snapshot, err ) in
            if let err = err{
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let User = User.init(dic: dic!)
            let noteFontSize = Float(User.noteFontSize)!
            let noteTextSpacingSize: Float = Float(User.noteTextSpacingSize)!
            let fontName = User.noteFont
            let attribute = [NSAttributedString.Key.kern: noteTextSpacingSize]
            self.PreViewTextView.attributedText = NSMutableAttributedString(string: PreViewTextView.text!, attributes: attribute)
            self.PreViewTextView.font = UIFont(name: fontName, size: CGFloat(noteFontSize))
            self.fontSizeSlider.value = noteFontSize
            self.textSpacingSizeSlider.value = noteTextSpacingSize
            if let firstIndex = fontList.firstIndex(of: "\(fontName)") {
                print("インデックス番号: \(firstIndex)")
                self.fontSelectPicker.selectRow(firstIndex, inComponent: 0, animated: false)
            }else{
                print("インデックス番号が取得できませんでした。")
            }
        }
    }
}
