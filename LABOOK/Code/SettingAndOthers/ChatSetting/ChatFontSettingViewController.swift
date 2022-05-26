//
//  ChatFontSettingViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/31.
//

import UIKit
import Firebase

private let cellId = "cellId"

class ChatFontSettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource  {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = chatPreviewTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatFontSettingTableViewCell
        
        if indexPath.row == 0 {
            cell = chatPreviewTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath as IndexPath) as! ChatFontSettingTableViewCell
            let ImageView = cell.contentView.viewWithTag(4) as! UIImageView
            ImageView.isHidden = true
            let textView = cell.contentView.viewWithTag(5) as! UITextView
            textView.isHidden = true
            let messageTime = cell.contentView.viewWithTag(6) as! UILabel
            messageTime.isHidden = true

        } else {
            cell = chatPreviewTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath as IndexPath) as! ChatFontSettingTableViewCell
            let ImageView = cell.contentView.viewWithTag(1) as! UIImageView
            ImageView.isHidden = true
            let textView = cell.contentView.viewWithTag(2) as! UITextView
            textView.isHidden = true
            let messageTime = cell.contentView.viewWithTag(3) as! UILabel
            messageTime.isHidden = true
            cell.myMessageTextView.font =  UIFont(name: chatFontList[1], size: 16)
            cell.partnerMessageTextView.font = UIFont(name: chatFontList[1], size: 16)
        }
        
        return cell
    }
    
    //メーセージの長さに応じて高さを変えるメソッド
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatPreviewTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }//△
    
    
    let chatFontList = [
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
    
    @IBOutlet weak var chatFontPicker: UIPickerView!
    @IBOutlet weak var chatPreviewTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatFontPicker.delegate = self
        chatFontPicker.dataSource = self
        chatPreviewTableView.delegate = self
        chatPreviewTableView.dataSource = self
        fecthChatFontData()
    }
    
    func fecthChatFontData(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("chatRoom").document(email).getDocument { [self](snapshot, err ) in
            if let err = err{
                print("ChatFontDataの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let ChatFontData = ChatRoom.init(dic: dic!)
            let fontName = ChatFontData.chatFont
            
            //上のCell
            let indexPath0 = IndexPath(row: 0, section: 0)
            let previewCell0 = chatPreviewTableView.cellForRow(at: indexPath0) as? ChatFontSettingTableViewCell
            previewCell0?.myMessageTextView.font = UIFont(name: fontName, size: 16)
            previewCell0?.partnerMessageTextView.font = UIFont(name: fontName, size: 16)
            //下のCell
            let indexPath1 = IndexPath(row: 1, section: 0)
            let previewCell1 = chatPreviewTableView.cellForRow(at: indexPath1) as? ChatFontSettingTableViewCell
            previewCell1?.myMessageTextView.font = UIFont(name: fontName, size: 16)
            previewCell1?.partnerMessageTextView.font = UIFont(name: fontName, size: 16)
            
            if let firstIndex = chatFontList.firstIndex(of: "\(fontName)") {
                self.chatFontPicker.selectRow(firstIndex, inComponent: 0, animated: false)
            }else{
                print("インデックス番号が取得できませんでした。")
            }
        }
    }
    
        // UIPickerViewの列の数
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        // UIPickerViewの行数、リストの数
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return chatFontList.count
        }
        
        // UIPickerViewの最初の表示
        func pickerView(_ pickerView: UIPickerView,
                        titleForRow row: Int,
                        forComponent component: Int) -> String? {
            return chatFontList[row]
        }
        
        // UIPickerViewのRowが選択された時の挙動
        func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {
            //上のCell
            let indexPath2 = IndexPath(row: 0, section: 0)
            let previewCell2 = chatPreviewTableView.cellForRow(at: indexPath2) as? ChatFontSettingTableViewCell
            previewCell2?.myMessageTextView.font = UIFont(name: chatFontList[row], size: 16)
            previewCell2?.partnerMessageTextView.font = UIFont(name: chatFontList[row], size: 16)
            //下のCell
            let indexPath3 = IndexPath(row: 1, section: 0)
            let previewCell3 = chatPreviewTableView.cellForRow(at: indexPath3) as? ChatFontSettingTableViewCell
            previewCell3?.myMessageTextView.font = UIFont(name: chatFontList[row], size: 16)
            previewCell3?.partnerMessageTextView.font = UIFont(name: chatFontList[row], size: 16)
            
            guard let email = Auth.auth().currentUser?.email else {return}
            Firestore.firestore().collection("chatRoom").document(email).updateData([
                "chatFont": chatFontList[row]
            ]) { err in
                if let err = err {
                    print("chatFontのアップデートに失敗しました。: \(err)")
                } else {
                    print("chatFontのアップデートに成功しました。")
                }
            }
        }
        
    }


//ユーザーのアイコン設定、テキストが見切れる
