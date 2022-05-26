//
//  PageViewController.swift
//  lovenote
//
//  Created by Koudai Okamura on 2022/01/29.
//

import UIKit
import Firebase
import FirebaseFirestore
import Nuke
import PKHUD

class PageViewController: UIViewController, UITextViewDelegate{
    
    var pageSubject: String!
    var editPageButtonItem: UIBarButtonItem!
    var noteUserEmail :String!
    
    @IBOutlet weak var PageUserNameLabel: UILabel!
    @IBOutlet weak var CreatePageDateLabel: UILabel!
    @IBOutlet weak var PageUserImageView: UIImageView!
    @IBOutlet weak var pageTextView: UITextView!
    @IBOutlet weak var pageThumnailImageView: UIImageView!
    @IBOutlet weak var commentBoxLabel: UILabel!
    @IBOutlet weak var commentUserImageView: UIImageView!
    @IBOutlet weak var commentUserNameLabel: UILabel!
    @IBOutlet weak var commentTextView: PlaceTextView!
    @IBOutlet weak var commentSaveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = pageSubject
        fetchNoteContent()
        fetchNoteFontData()
        fetchCommentInfo()
        commentUserImageView.layer.cornerRadius = 30
        PageUserImageView.layer.cornerRadius = 35
        commentSaveButton.layer.cornerRadius = 30
        commentBoxLabel.layer.cornerRadius = 3
        commentTextView.placeHolder = "Aa"
        commentTextView.delegate = self
        editPageButtonItem = UIBarButtonItem(title: "編集", style: .done, target: self, action: #selector(editPageButtonPressed(_:)))
        //キーボード関連
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func fetchNoteContent(){
        
        Firestore.firestore().collection("note").document(noteUserEmail).collection("pages").document(pageSubject).getDocument { [self](snapshot, err ) in
            if let err = err{
                print("ページ情報の取得に失敗しました。\(err)")
                return
            }
            
            let dic = snapshot?.data()
            let page = Page.init(dic: dic!)
            guard let myEmail = Auth.auth().currentUser?.email else {return}
            if myEmail == noteUserEmail{
                self.navigationItem.rightBarButtonItem = editPageButtonItem
            }
            
            let pageContent = page.pageContent
            pageTextView.text = pageContent
            CreatePageDateLabel.text = dateFormatterForDateLabel(date: page.createAt.dateValue())
            let thumnaillUrl = URL(string: page.thunailsImageView)!
            Nuke.loadImage(with: thumnaillUrl, into: self.pageThumnailImageView)
            let userName = page.userName
            PageUserNameLabel.text = "From：\(userName)"
            let userImageViewUrl =  URL(string: page.userImageUrl)!
            Nuke.loadImage(with: userImageViewUrl, into: self.PageUserImageView)
            let commentText = page.commentText
            commentTextView.text = commentText
            
        }
    }
    
    func fetchNoteFontData(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument { [self](snapshot, err ) in
            if let err = err{
                print("ノート情報の取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let User = User.init(dic: dic!)
            let fontsize = Float(User.noteFontSize)!
            let textspacingsize: Float = Float(User.noteTextSpacingSize)!
            let fontName = User.noteFont
            let attribute = [NSAttributedString.Key.kern: textspacingsize]
            self.pageTextView.attributedText = NSMutableAttributedString(string: pageTextView.text!, attributes: attribute)
            self.pageTextView.font = UIFont(name: fontName, size: CGFloat(fontsize))
        }
        
    }
    
    func fetchCommentInfo(){
        
        guard let myEmail = Auth.auth().currentUser?.email else {return}
        //ノートの作成者が自分のなら相手の情報を取得し、コメントに表示
        if noteUserEmail == myEmail{
            Firestore.firestore().collection("users").document(myEmail).getDocument { (snapshot, err ) in
                if let err = err{
                    print("ノート情報の取得に失敗しました。\(err)")
                    return
                }
                let dic = snapshot?.data()
                let User = User.init(dic: dic!)
                let partnerEmail = User.partnerEmail
                
                Firestore.firestore().collection("users").document(partnerEmail).getDocument { (snapshot, err ) in
                    if let err = err{
                        print("ノート情報の取得に失敗しました。\(err)")
                        return
                    }
                    let dic = snapshot?.data()
                    let Partner = Partner.init(dic: dic!)
                    let partnerName = Partner.username
                    self.commentUserNameLabel.text = partnerName
                    let url = URL(string: Partner.profileImageUrl)!
                    Nuke.loadImage(with: url, into: self.commentUserImageView)
                }
            }
            //ノートの作成者が自分ではないなら、自分の情報を取得し、コメントに表示
        }else{
            Firestore.firestore().collection("users").document(myEmail).getDocument { (snapshot, err ) in
                if let err = err{
                    print("ノート情報の取得に失敗しました。\(err)")
                    return
                }
                let dic = snapshot?.data()
                let User = User.init(dic: dic!)
                self.commentUserNameLabel.text = "あなた"
                let url = URL(string: User.profileImageUrl)!
                Nuke.loadImage(with: url, into: self.commentUserImageView)
            }
        }
        
        //表示する投稿が自分の投稿の時、コメントの編集、保存ボタン無効
        if myEmail == noteUserEmail{
            commentTextView.isEditable = false
            commentSaveButton.isEnabled = false
            //表示する投稿が相手の投稿の時、コメントの編集、保存ボタン有効
        }else{
            commentTextView.isEditable = true
            commentSaveButton.isEnabled = true
            
        }
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    func textViewDidChange(_ textView: UITextView){
        if commentTextView.text.count > 0 {
            commentSaveButton.isEnabled = true
        }else{
            commentSaveButton.isEnabled = false
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
                        "transitionSource": "PageViewController",
                        "noticeMessage": "ノートにコメントしました！",
                        "noticeImageView": userImage,
                        "pageSubject": self.pageSubject!,
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
    
    @IBAction func commentSaveButton(_ sender: Any) {
        guard let commentTextView = commentTextView.text else { return }
        Firestore.firestore().collection("note").document(noteUserEmail).collection("pages").document(pageSubject).updateData([
            "commentText": commentTextView
        ]) { err in
            if let err = err {
                print("ノートコメントを保存できませんでした。: \(err)")
            } else {
                self.sendNotice()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    HUD.flash(.success, delay: 1.0)
                }
            }
        }
    }
    
    @objc func editPageButtonPressed(_ sender: UIBarButtonItem) {
        
        let storyboard: UIStoryboard = self.storyboard!
        let VC = storyboard.instantiateViewController(withIdentifier: "CreatePage") as! CreatePageViewController
        VC.pageSubject = pageSubject
        VC.whetherFromPage = true
        VC.editPage()
        navigationController?.pushViewController(VC, animated: false)
        
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)//他の画面をタップでキーボードを閉じる
    }
    
    //以下2つ、textfieldと一緒にキーボードを動かす
    @objc func keyboardWillShow(notification: NSNotification) {
        if !commentTextView.isFirstResponder {
            return
        }
        
        if self.view.frame.origin.y == 0 {
            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= (keyboardRect.height - 175)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    
}
