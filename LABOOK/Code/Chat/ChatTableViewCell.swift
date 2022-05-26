//
//  ChatTableViewCell.swift
//  lovenote
//
//  Created by Koudai Okamura on 2022/01/26.
//チャット用のセルに対するコードを書くファイル

import UIKit
import Firebase
import Nuke

class chatTableViewCell: UITableViewCell{
    
    var message: Message?
    
    @IBOutlet weak var partnerMessageImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var myMessageImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        partnerMessageImageView.layer.cornerRadius = 25
        myMessageImageView.layer.cornerRadius = 25
        partnerMessageTextView.layer.cornerRadius = 15
        myMessageTextView.layer.cornerRadius = 15
        
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("chatRoom").document(email).getDocument { (snapshot, err) in
            if let err = err{
                print("チャット情報の取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let ChatRoom = ChatRoom.init(dic: dic!)
            let chatFont = ChatRoom.chatFont
            self.myMessageTextView.font = UIFont(name: chatFont, size: 16)
            self.partnerMessageTextView.font = UIFont(name: chatFont, size: 16)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhitchMessage()
    }
    //文字列の長さを測定
    private func estimateFrameForTextView(text: String) -> CGRect{
        
        //Max width and height
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String{
        let formatter = DateFormatter()
        
        let calendar = Calendar(identifier: .japanese)
        let today = Date()
        
        if calendar.isDateInToday(today) == true{ //今日なら
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ja_JP")
        }else{
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "ja_JP")
        }
        
        
        return formatter.string(from: date)
    }
    
    private func checkWhitchMessage(){
        guard let email = Auth.auth().currentUser?.email else {return}
        //自分のメッセージを表示
        if email == message?.email{
            partnerDateLabel.isHidden = true
            partnerMessageTextView.isHidden = true
            partnerMessageImageView.isHidden = true
            myDateLabel.isHidden = false
            myMessageTextView.isHidden = false
            myMessageImageView.isHidden = false
            
            if let message = message {
                myMessageTextView.text = message.message
                myDateLabel.text = dateFormatterForDateLabel(date: message.createAt.dateValue())
                let width = estimateFrameForTextView(text: message.message).width + 50
                myMessageTextWidthConstraint.constant = width
                let url = URL(string: message.profileImageUrl)
                Nuke.loadImage(with: url, into: myMessageImageView)
    
            }
            
         //パートナーのメッセージを表示
        }else{
            partnerDateLabel.isHidden = false
            partnerMessageTextView.isHidden = false
            partnerMessageImageView.isHidden = false
            myDateLabel.isHidden = true
            myMessageTextView.isHidden = true
            myMessageImageView.isHidden = true
            
            if let message = message {
                partnerMessageTextView.text = message.message
                partnerDateLabel.text = dateFormatterForDateLabel(date: message.createAt.dateValue())
                let width = estimateFrameForTextView(text: message.message).width + 50
                partnerMessageTextWidthConstraint.constant = width
                let url = URL(string: message.profileImageUrl)
                Nuke.loadImage(with: url, into: partnerMessageImageView)
            }
        }
        
    }
}
