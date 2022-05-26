//
//  ChatViewController.swift
//  lovenote
//
//  Created by Koudai Okamura on 2022/01/26.
//

import UIKit
import Firebase
import FirebaseFirestore
import Nuke

private let cellId = "cellId"
private var messages = [Message]()

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    var settingsButtonItem: UIBarButtonItem!
    var partnerEmail :String!
    var toolBar:UIToolbar!

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatInputTextView: PlaceTextView!
    @IBOutlet weak var messageSendButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! chatTableViewCell
        cell.message = messages[indexPath.row]
        return cell
        
    }
    //メーセージの長さに応じて高さを変えるメソッド
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMessages()
        mixPartnerMessages()
        setUpToolbar()
        self.chatTableView.backgroundView = nil
        chatInputTextView.placeHolder = "メッセージを入力"
        settingsButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingsButtonPressed(_:)))
        settingsButtonItem.tintColor = UIColor.black
        noticeButtonItem = UIBarButtonItem(title: "通知", style: .done, target: self, action: #selector(noticeButtonPressed(_:)))
        noticeButtonItem.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItems = [settingsButtonItem,noticeButtonItem]
        self.navigationItem.rightBarButtonItems = [settingsButtonItem,noticeButtonItem]
        self.navigationItem.leftBarButtonItem = datingdDateBottonItem
        chatInputTextView.layer.cornerRadius = 10
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil),forCellReuseIdentifier: cellId) //作ったチャット用のセルを使用するセルとして登録
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR) //他の画面をタップでキーボードを閉じる
        
        //以下2行、textViewと一緒にキーボードを動かす
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        chatInputTextView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fecthChatBackgroundImageAndFontData()
        fetchNoticesData()
    }
    
    func setUpToolbar(){
           toolBar = UIToolbar()
           toolBar.sizeToFit()
           let toolBarButton = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(doneButton))
           toolBar.items = [toolBarButton]
           chatInputTextView.inputAccessoryView = toolBar
       }
    
    @objc func doneButton(){
        chatInputTextView.resignFirstResponder()
    }
    
    func fecthChatBackgroundImageAndFontData(){
        
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("chatRoom").document(email).getDocument { (snapshot, err) in
            if let err = err{
                print("チャット情報の取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let chatRoom = ChatRoom.init(dic: dic!)
            self.partnerEmail = chatRoom.partnerEmail
            let chatFont = chatRoom.chatFont
            self.chatInputTextView.font = UIFont(name: chatFont, size: 17)
            let chatBackgroundImage = chatRoom.chatBackgroundImage
            // もしChatBackGroundImagePreviewImageViewが短かったら、それはアセット画像
            let chatBackgroundImageLength = chatBackgroundImage.count
            if chatBackgroundImageLength <= 10 {
                
                let image = UIImage(named: chatBackgroundImage)
                self.backgroundImageView.image = image
             
            // もしChatBackGroundImagePreviewImageViewが長かったら、それはURL
            } else {
                if let url = URL(string: chatRoom.chatBackgroundImage){
                    Nuke.loadImage(with: url, into: self.backgroundImageView)

                }
            }
        }
    }
    
    func fetchNoticesData(){
           guard let email = Auth.auth().currentUser?.email else {return}
           Firestore.firestore().collection("users").document(email).collection("notices").addSnapshotListener{ (snapshots, err) in
               if let err = err{
                   print("ノート情報の取得に失敗しました。\(err)")
                   return
               }
               snapshots?.documentChanges.forEach { (documentChange) in
                   
                   switch documentChange.type{
                   case .added:
                       let dic = documentChange.document.data()
                       let notice = Notice(dic: dic)
                       if notice.changeSettingTextToRed == true{
                           noticeButtonItem.tintColor = UIColor.red
                       }
                      
                   case .modified:
                       print("nothing to do")
                   case .removed:
                       print("nothing to do")
                   }
               }
           }
       }

    
    func fetchMessages(){
        
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("chatRoom").document(email).collection("messages").addSnapshotListener { (snapshots, err) in
            if let err = err{
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documentChanges.forEach { (documentChange) in
                
                switch documentChange.type{
                    
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    messages.append(message)
                    //時刻で並び替え
                    messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createAt.dateValue()
                        let m2Date = m2.createAt.dateValue()
                        return m1Date < m2Date
                        
                    }
                    self.chatTableView.reloadData()
                    //メッセージを追加した際に底までスクロール
                    self.chatTableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: false)
                case .modified:
                    print("nothing to do")
                case .removed:
                    print("nothing to do")
                }
            }
        }
    }
    
    func mixPartnerMessages(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument { (snapshot, err) in
            if let err = err{
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let user = User.init(dic: dic!)
            self.partnerEmail = user.partnerEmail
            
            Firestore.firestore().collection("chatRoom").document(self.partnerEmail).collection("messages").addSnapshotListener { (snapshots, err) in
                if let err = err{
                    print("メッセージ情報の取得に失敗しました。\(err)")
                    return
                }
                snapshots?.documentChanges.forEach { (documentChange) in
                    
                    switch documentChange.type{
                        
                    case .added:
                        let dic = documentChange.document.data()
                        let message = Message(dic: dic)
                        messages.append(message)
                        //時刻で並び替え
                        messages.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createAt.dateValue()
                            let m2Date = m2.createAt.dateValue()
                            return m1Date < m2Date
                            
                        }
                        self.chatTableView.reloadData()
                        //メッセージを追加した際に底までスクロール
                        self.chatTableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: false)
                    case .modified:
                        print("nothing to do")
                    case .removed:
                        print("nothing to do")
                    }
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        //path
    }
    
    //以下2つ、textfieldと一緒にキーボードを動かす
    @objc func keyboardWillShow(notification: NSNotification) {
        if !chatInputTextView.isFirstResponder {
            return
        }
        
        if self.view.frame.origin.y == 0 {
            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= (keyboardRect.height - 80) //※80は応急処置！後で直す。
            }
        }
    }
    
    @IBAction func tappedSendButton(_ sender: Any) {
        
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument { (snapshot, err) in
            if let err = err{
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let user = User.init(dic: dic!)
            let profileImageUrl = user.profileImageUrl
            
            let docData = [
                "createdAt": Timestamp(),
                "email" : email,
                "message": self.chatInputTextView.text!,
                "profileImageUrl": profileImageUrl
            ] as [String : Any]
            
            Firestore.firestore().collection("chatRoom").document(email).collection("messages").document().setData(docData) { (err) in
                if let err = err {
                    print("メッセージ情報の保存に失敗しました。\(err)")
                    return
                }
            }
            self.chatInputTextView.resignFirstResponder()
            self.chatInputTextView.text = ""
            self.messageSendButton.isEnabled = false
            self.sendNotice()
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
                        "transitionSource": "ChatViewController",
                        "noticeMessage": "チャットにメッセージを送りました！",
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
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textViewDidChange(_ textView: UITextView){
        if textView.text.isEmpty {
            messageSendButton.isEnabled = false
        }else{
            messageSendButton.isEnabled = true
        }
    }
    
    @objc func settingsButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = self.storyboard!
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingViewController")
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func noticeButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = self.storyboard!
        let vc = storyboard.instantiateViewController(withIdentifier: "checkNotice")
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav,animated: true)
    }
    
}


//絵文字検索をすると、フィールドが埋もれる
