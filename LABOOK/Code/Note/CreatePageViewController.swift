//
//  CreatePageViewController.swift
//  lovenote
//
//  Created by Koudai Okamura on 2022/02/03.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Nuke
import PKHUD

class CreatePageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    
    var pageSubject: String!
    var createPageButtonItem: UIBarButtonItem!
    var tipPageButtonItem: UIBarButtonItem!
    var noteUserImageUrl:String!
    var updatedNextSubjectList = [String]()
    var whetherFromPage:Bool!
    var toolBar:UIToolbar!
    
    //pickerの設定
    var nextSujectList = [
        "改めて自己紹介をどうぞ！","今後二人で行ってみたいところは？","ペットを飼うなら何？","印象に残っている二人の思い出は？","実はこんなところにキュンとしています！","もっと良い関係になるためには？","初対面の印象をお願いします！","最近悩んでいることは？","日頃の感謝を聞きたい！","1億円当たったらどうする？","最近のマイブームは？","今日はどんな1日だった？"
    ]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return updatedNextSubjectList.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return updatedNextSubjectList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        nextSubjectField.text = updatedNextSubjectList[row]
    }
    
    @IBOutlet weak var setThumbnailButton: UIButton!
    @IBOutlet weak var PageUserImageView: UIImageView!
    @IBOutlet weak var pageTextView: PlaceTextView!
    @IBOutlet weak var PageUserNameLabel: UILabel!
    @IBOutlet weak var sendNoteView: UIView!
    @IBOutlet weak var nextSubjectField: UITextField!
    @IBOutlet weak var sendNoteInUIView: UIView!
    @IBOutlet weak var nextSubjectPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchNoteFontData()
        fetchCurrentUserData()
        updateNextSujectList()
        setUpToolbar()
        pageTextView.delegate = self
        nextSubjectPickerView.delegate = self
        nextSubjectPickerView.dataSource = self
        
        if whetherFromPage == true{
            pageTextView.placeHolder = ""
        }else{
            pageTextView.placeHolder = "入力してください。"
            self.title = pageSubject
        }
        PageUserImageView.layer.cornerRadius = 35
        createPageButtonItem = UIBarButtonItem(title: "投稿", style: .done, target: self, action: #selector(createPageButtonPressed(_:)))
        createPageButtonItem.tintColor = UIColor.black
        tipPageButtonItem = UIBarButtonItem(title: "ヒント", style: .done, target: self, action: #selector(tipPageButtonPressed(_:)))
        createPageButtonItem.tintColor = UIColor.blue
        tipPageButtonItem.tintColor = UIColor.black
        createPageButtonItem.isEnabled = false
        self.navigationItem.rightBarButtonItems = [createPageButtonItem,tipPageButtonItem]
        //createPageButtonItem.isEnabled = false
        sendNoteView.backgroundColor = UIColor(red: 0,green: 0,blue: 0,alpha: 0.7)
        self.navigationController?.view.addSubview(self.sendNoteView)
        sendNoteInUIView.layer.cornerRadius = 10
        sendNoteView.isHidden = true
        
    }
    
    func setUpToolbar(){
        toolBar = UIToolbar()
        toolBar.sizeToFit()
        let toolBarButton = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(doneButton))
        toolBar.items = [toolBarButton]
        pageTextView.inputAccessoryView = toolBar
    }
    
    @objc func doneButton(){
        pageTextView.resignFirstResponder()
    }
    
    @objc func createPageButtonPressed(_ sender: UIBarButtonItem) {
        pageTextView.resignFirstResponder()
        //編集中の投稿が新規かどうか判定
        if whetherFromPage == false{
            sendNoteView.isHidden = false
        }else{
            //新規ではないならupdateする
            let thunailsImageView = setThumbnailButton.imageView?.image ?? UIImage(named: "C47882BF-DF3B-4EA7-8214-B2C1BB1587FA")
            
            guard let uploadthunailsImageView = thunailsImageView?.jpegData(compressionQuality: 0.5) else {return}
            let fileName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("thumnail_image").child(fileName)
            
            storageRef.putData(uploadthunailsImageView, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("Firebaseへのサムネイル画像の保存に失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                storageRef.downloadURL { (url, err) in
                    if let err = err{
                        print("Firebaseからのサムネイル画像のダウンロードに失敗しました。\(err)")
                        HUD.hide()
                        return
                    }
                    guard let urlString = url?.absoluteString else {return}
                    guard let myEmail = Auth.auth().currentUser?.email else {return}
                    Firestore.firestore().collection("note").document(myEmail).collection("pages").document(self.pageSubject).updateData([
                        "pageContent": self.pageTextView.text!,
                        "thunailsImageView": urlString
                    ]) { err in
                        if let err = err {
                            print("ノートのアップデートに失敗しました。: \(err)")
                            HUD.hide()
                        } else{
                            HUD.hide()
                            print("ノートのアップデートに成功しました。")
                            HUD.flash(.label("アップデート中です"), delay: 0.8) { _ in
                                HUD.show(.progress)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    HUD.flash(.success, delay: 1.0)
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @objc func tipPageButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = self.storyboard!
        let VC = storyboard.instantiateViewController(withIdentifier: "noteTips")
        self.present(VC,animated: true)
    }
    
    
    @IBAction func setThumbnailButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            setThumbnailButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[.originalImage] as? UIImage{
            setThumbnailButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
        setThumbnailButton.imageView?.contentMode = .scaleAspectFit
        setThumbnailButton.setTitle("", for: .normal)
        setThumbnailButton.contentHorizontalAlignment = .fill
        setThumbnailButton.contentVerticalAlignment = .fill
        setThumbnailButton.clipsToBounds = true
        dismiss(animated:true, completion: nil)
    }
    
    func updateNextSujectList(){
        
        updatedNextSubjectList.removeAll()
        updatedNextSubjectList = nextSujectList
        guard let myEmail = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(myEmail).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let user = User.init(dic: dic!)
            let myPartnerEmail = user.partnerEmail
            
            Firestore.firestore().collection("note").document(myPartnerEmail).collection("pages").addSnapshotListener { (snapshots, err) in
                if let err = err{
                    print("パートナーのノート情報の取得に失敗しました。\(err)")
                    return
                }
                snapshots?.documentChanges.forEach { (documentChange) in
                    
                    switch documentChange.type{
                        
                    case .added:
                        let dic = documentChange.document.data()
                        let page = Page(dic: dic)
                        let answeredSubject = page.pageSubject
                        self.updatedNextSubjectList.removeAll(where: { $0 == answeredSubject })
                        
                    case .modified:
                        print("nothing to do")
                        
                    case .removed:
                        print("nothing to do")
                        
                    }
                }
            }
        }
        
    }
    
    func fetchCurrentUserData(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let User = User.init(dic: dic!)
            let UserName = User.username
            let fromSendUserLabel = "From \(UserName)"
            self.PageUserNameLabel.text = fromSendUserLabel
            let url = URL(string: User.profileImageUrl)!
            self.noteUserImageUrl = User.profileImageUrl //保存用
            Nuke.loadImage(with: url, into: self.PageUserImageView)
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
    
    func textViewDidChange(_ textView: UITextView){
        if pageTextView.text.count > 0 {
            createPageButtonItem.isEnabled = true
        }else{
            createPageButtonItem.isEnabled = false
        }
        
    }
    
    func textFieldDidChange(_ nextSubjectField: UITextField) {
        let charactersCount = nextSubjectField.text?.count ?? 0
        if charactersCount > 0 {
            
            createPageButtonItem.isEnabled = false
        }else{
            createPageButtonItem.isEnabled = true
        }
    }
    
    
    @IBAction func sendNoteButton(_ sender: Any) {
        
        HUD.show(.progress)
        //サムネイル処理
        let thunailsImageView = setThumbnailButton.imageView?.image ?? UIImage(named: "C47882BF-DF3B-4EA7-8214-B2C1BB1587FA")
        
        guard let uploadthunailsImageView = thunailsImageView?.jpegData(compressionQuality: 0.5) else {return}
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("thumnail_image").child(fileName)
        
        storageRef.putData(uploadthunailsImageView, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firebaseへのサムネイル画像の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            storageRef.downloadURL { (url, err) in
                if let err = err{
                    print("Firebaseからのサムネイル画像のダウンロードに失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                guard let urlString = url?.absoluteString else {return}
                guard let email = Auth.auth().currentUser?.email else {return}
                Firestore.firestore().collection("users").document(email).getDocument { (snapshot, err ) in
                    if let err = err{
                        print("ログインユーザーの取得に失敗しました。\(err)")
                        HUD.hide()
                        return
                    }
                    let dic = snapshot?.data()
                    let User = User.init(dic: dic!)
                    //let userImageUrl = URL(string: User.profileImageUrl)!
                    let userName = User.username
                    let commentText = ""
                    //ユーザーの名前と時刻とサムネイル画像とTextViewの内容をFirebaseに保存
                    guard let nextSubject = self.nextSubjectField.text else {return}
                    let docData = [
                        "createdAt": Timestamp(),
                        "email" : email,
                        "nextSubject": nextSubject,
                        "pageSubject": self.pageSubject!,
                        "pageContent": self.pageTextView.text!,
                        "userImageUrl": self.noteUserImageUrl!,
                        "thunailsImageView": urlString,
                        "userName": userName,
                        "commentText": commentText
                    ] as [String : Any]
                    
                    Firestore.firestore().collection("note").document(email).collection("pages").document(self.pageSubject).setData(docData) { (err) in
                        if let err = err {
                            print("新規ノート情報の保存に失敗しました。\(err)")
                            HUD.hide()
                            return
                        }
                        print("新規ノート情報の保存に成功しました。")
                        self.sendNotice()
                    }
                }
            }
        }
        sendNoteView.isHidden = true
        HUD.hide()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func editPage(){//編集する際に使うメソッド
        print{"editPageメソッドが呼び出されました。"}
        guard let myEmail = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("note").document(myEmail).collection("pages").document(pageSubject).getDocument { (snapshot, err ) in
            if let err = err{
                print("ページ情報の取得に失敗しました。\(err)")
                return
            }
            
            let dic = snapshot?.data()
            let page = Page.init(dic: dic!)
            self.title = page.pageSubject
            self.pageTextView.text = page.pageContent
            let userName = page.userName
            self.PageUserNameLabel.text = "From：\(userName)"
            let userImageViewUrl =  URL(string: page.userImageUrl)!
            Nuke.loadImage(with: userImageViewUrl, into: self.PageUserImageView)
            
            let thumnaillUrl = URL(string: page.thunailsImageView)!
            ImagePipeline.shared.loadImage(with: thumnaillUrl) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.setThumbnailButton.setImage(data.image, for: .normal)
                    }
                case .failure:
                    break
                }
            }
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
                "email": email,
                "userName": userName,
                "transitionSource": "PageViewController",
                "pageSubject": self.pageSubject!,
                "noticeMessage": "ノートを新しく投稿しました！",
                "noticeImageView": userImage,
                "changeSettingTextToRed": true
            ] as [String : Any]
            
            Firestore.firestore().collection("users").document(partnerEmail).collection("notices").document().setData(docData){ err in
                if let err = err{
                    print("noticeの保存に失敗しました。\(err)")
                }else{
                    //                    let content = UNMutableNotificationContent()
                    //                    content.title = "お知らせ"
                    //                    content.body = "ボタンを押しました。"
                    //                    content.sound = UNNotificationSound.default
                    //
                    //                    // 直ぐに通知を表示
                    //                    let request = UNNotificationRequest(identifier: "immediately", content: content, trigger: nil)
                    //                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
            }
        }
    }
    
    func updatedNotice(){
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
                "noticeMessage": "ノートを編集しました！",
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
    
    
    @IBAction func backButton(_ sender: Any) {
        sendNoteView.isHidden = true
    }
    
    private func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false //textFieldのキーボードを出させなくなるはず。
    }
    
}
