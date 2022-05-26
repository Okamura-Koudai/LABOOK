//
//  NoteViewController.swift
//  lovenote
//
//  Created by Koudai Okamura on 2022/01/25.
//

import UIKit
import Firebase
import FirebaseFirestore
import Nuke

private var pages = [Page]()
private let cellId = "cellId"
var noticeButtonItem: UIBarButtonItem!//共通で設定できているはず
var datingdDateBottonItem: UIBarButtonItem!
var nextPageSubject: String!
var dayInterval:Int!
var datingDateLabel = "交際\(dayInterval ?? 1)日"

class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, number: Int) -> Int {
            return 1
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ページ数：",pages.count)
        return pages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NoteTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        //tag1
        let NoteUserImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let userUrl = URL(string: pages[indexPath.row].userImageUrl)//out of index
        Nuke.loadImage(with: userUrl, into: NoteUserImageView)
        NoteUserImageView.layer.cornerRadius = 35
        //tag2
        let NoteSujectLabel = cell.contentView.viewWithTag(2) as! UILabel
        NoteSujectLabel.text = pages[indexPath.row].pageSubject
        //tag3
        let NoteDateLabel = cell.contentView.viewWithTag(3) as! UILabel
        NoteDateLabel.text = dateFormatterForDateLabel(date: (pages[indexPath.row].createAt.dateValue()))
        //tag4
        let thunailsImageView = cell.contentView.viewWithTag(4) as! UIImageView
        let thumnailUrl = URL(string: pages[indexPath.row].thunailsImageView)
        Nuke.loadImage(with: thumnailUrl, into: thunailsImageView)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let vc = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
        vc.pageSubject = pages[indexPath.row].pageSubject
        vc.noteUserEmail = pages[indexPath.row].email
        navigationController?.pushViewController(vc, animated: true)
    }
    
    var settingsButtonItem: UIBarButtonItem!
    @IBOutlet weak var TopPageButtonLabel: UIButton!
    @IBOutlet weak var TopPageImageView: UIImageView!
    @IBOutlet weak var TopPageThumbnailImageView: UIImageView!
    @IBOutlet weak var noPageButton: UIButton!
    @IBOutlet weak var NoteTableView: UITableView!
    @IBOutlet weak var noPageView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ResetAndFetchMyNote()
        fetchAndCalculateDateNumberAndUpdate()
        fetchNoticesData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noPageButton.layer.cornerRadius = 20
        NoteTableView.delegate = self
        NoteTableView.dataSource = self
        settingsButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingsButtonPressed(_:)))
        settingsButtonItem.tintColor = UIColor.black
        noticeButtonItem = UIBarButtonItem(title: "通知", style: .done, target: self, action: #selector(noticeButtonPressed(_:)))
        noticeButtonItem.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItems = [settingsButtonItem,noticeButtonItem]
        
    }
    
    func fetchAndCalculateDateNumberAndUpdate(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument { (snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let user = User.init(dic: dic!)
            let startDatingDate = user.startDatingDate
            dayInterval = ((Calendar.current.dateComponents([.day], from: startDatingDate , to: Date())).day!) + 1
            datingdDateBottonItem = UIBarButtonItem(title: datingDateLabel, style: .done, target: self, action: #selector(self.datingdDateBottonPressed(_:)))
            datingdDateBottonItem.tintColor = UIColor.black
            self.navigationItem.leftBarButtonItem = datingdDateBottonItem
        }
    }
    
    func showTopButtonLabel(){
        guard let email = Auth.auth().currentUser?.email else {return}
        let lastNoteEmail = pages.last?.email
        //最後の投稿がない
            if pages.isEmpty == true {
            TopPageButtonLabel.setTitle("ノートを書いてみましょう(→執筆)", for: .normal)
            TopPageImageView.image = UIImage(systemName: "pencil.circle.fill")
            TopPageImageView.tintColor = .red
            TopPageThumbnailImageView.isHidden = true
            
        //最後の投稿が自分
        }else if lastNoteEmail == email {
            TopPageButtonLabel.setTitle("投稿完了(→再度編集する)", for: .normal)
            let lastNoteImageViewUrl =  URL(string: pages.last!.thunailsImageView)
            Nuke.loadImage(with: lastNoteImageViewUrl, into: self.TopPageThumbnailImageView)
            
        //最後の投稿が自分ではない
        }else if lastNoteEmail != email {
            TopPageButtonLabel.setTitle("ノートが回ってきました(→執筆)", for: .normal)
            TopPageImageView.image = UIImage(systemName: "pencil.circle.fill")
            TopPageImageView.tintColor = .red
            TopPageThumbnailImageView.isHidden = true
        }
    }
    
    func ResetAndFetchMyNote(){
        pages.removeAll()
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("note").document(email).collection("pages").addSnapshotListener { (snapshots, err) in
            if let err = err{
                print("ノート情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documentChanges.forEach { (documentChange) in
                
                switch documentChange.type{
                    
                case .added:
                    let dic = documentChange.document.data()
                    let page = Page(dic: dic)
                    pages.append(page)
                    //時刻で並び替え
                    pages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createAt.dateValue()
                        let m2Date = m2.createAt.dateValue()
                        return m1Date < m2Date
                        
                    }
                   
                case .modified:
                    print("nothing to do")
                case .removed:
                    print("nothing to do")
                }
            }
            self.addPartnerNote()
        }
    }
    
    func addPartnerNote(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument { (snapshot, err ) in
            if let err = err{
                print("ノート情報の取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let partner = Partner.init(dic: dic!)
            let partnerEmail = partner.partnerEmail
            
            Firestore.firestore().collection("note").document(partnerEmail).collection("pages").addSnapshotListener { (snapshots, err) in
                if let err = err{
                    print("パートナーのノート情報の取得に失敗しました。\(err)")
                    return
                }
                snapshots?.documentChanges.forEach { (documentChange) in
                    
                    switch documentChange.type{
                        
                    case .added:
                        let dic = documentChange.document.data()
                        let partnerPage = Page(dic: dic)
                        pages.append(partnerPage)
                        //時刻で並び替え
                        pages.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createAt.dateValue()
                            let m2Date = m2.createAt.dateValue()
                            return m1Date < m2Date
                            
                        }
                        self.NoteTableView.scrollToRow(at: IndexPath(row: pages.count - 1, section: 0), at: .bottom, animated: false)
                        
                    case .modified:
                        print("nothing to do")
                    case .removed:
                        print("nothing to do")//なぜかこれが呼ばれている
                    }
                }
            nextPageSubject = pages.last?.netxtSuject //投稿作成の際に渡すお題をここで取得
            print("次のお題：\(String(describing: nextPageSubject))") //nil
            self.showTopButtonLabel()
            if pages.count == 0{
                self.NoteTableView.isHidden = true
            }else{
                self.NoteTableView.isHidden = false
            }//あんまりうまく切り替わってくれない
            self.NoteTableView.reloadData()
            }
        }
    }
    
    func fetchNoticesData(){
        noticeButtonItem.tintColor = UIColor.black//リセット
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

    
    @IBAction func noPageButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let VC = storyboard.instantiateViewController(withIdentifier: "CreatePage") as! CreatePageViewController
        VC.pageSubject = "改めて自己紹介をどうぞ！"
    }
    
    @IBAction func TopPageButtonLabel(_ sender: UIButton){
        if TopPageButtonLabel.currentTitle == "投稿完了(→再度編集する)" {
            
            let storyboard: UIStoryboard = self.storyboard!
            let VC = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
            VC.pageSubject = pages.last?.pageSubject
            VC.noteUserEmail = pages.last?.email
            navigationController?.pushViewController(VC, animated: true)
            
        }else if TopPageButtonLabel.currentTitle == "ノートが回ってきました(→執筆)"{
            
            let storyboard: UIStoryboard = self.storyboard!
            let VC = storyboard.instantiateViewController(withIdentifier: "CreatePage") as! CreatePageViewController
            VC.pageSubject = nextPageSubject
            VC.whetherFromPage = false
            navigationController?.pushViewController(VC, animated: true)
            
        }else if TopPageButtonLabel.currentTitle == "ノートを書いてみましょう(→執筆)"{
            let storyboard: UIStoryboard = self.storyboard!
            let VC = storyboard.instantiateViewController(withIdentifier: "CreatePage") as! CreatePageViewController
            VC.pageSubject = "改めて自己紹介をどうぞ！"//効いていない
            VC.whetherFromPage = false
            navigationController?.pushViewController(VC, animated: true)
            
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
    
    @objc func datingdDateBottonPressed(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = self.storyboard!
        let vc = storyboard.instantiateViewController(withIdentifier: "ToDatingDate")
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav,animated: true)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
