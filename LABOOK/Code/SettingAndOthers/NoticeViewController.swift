//
//  NoticeViewController.swift
//  lovenote
//
//  Created by Koudai Okamura on 2022/01/26.
//

import UIKit
import Firebase
import Nuke

class NoticeViewController: UIViewController, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private let cellId = "cellId"
    var notices = [Notice]()
    var whetherNoticeTextColorChange:Bool = false
    @IBOutlet weak var NoticeTableView: UITableView!
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NoticeTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let noticeImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let noticeUser = cell.contentView.viewWithTag(2) as! UILabel
        let noticeMessage = cell.contentView.viewWithTag(3) as! UILabel
        let noticeDate = cell.contentView.viewWithTag(4) as! UILabel
        noticeImageView.layer.cornerRadius = 35
        
        if notices[indexPath.row].noticeImageView == "C47882BF-DF3B-4EA7-8214-B2C1BB1587FA"{
            noticeImageView.image = UIImage(named: "C47882BF-DF3B-4EA7-8214-B2C1BB1587FA")
        }else{
            let noticeImageUrl = URL(string: notices[indexPath.row].noticeImageView)
            Nuke.loadImage(with: noticeImageUrl, into: noticeImageView)
        }
        
        noticeUser.text = "\(notices[indexPath.row].userName)より"
        noticeMessage.text = notices[indexPath.row].noticeMessage
        noticeDate.text = dateFormatterForDateLabel(date: (notices[indexPath.row].createAt.dateValue()))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if notices[indexPath.row].transitionSource != ""{
            
            if  notices[indexPath.row].transitionSource == "PageViewController" {
                let pageViewController = storyboard!.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
                pageViewController.noteUserEmail = notices[indexPath.row].email
                pageViewController.pageSubject = notices[indexPath.row].pageSubject
                self.present(pageViewController,animated: false)
                
            }else{
                let vc = storyboard!.instantiateViewController(withIdentifier: notices[indexPath.row].transitionSource)
                self.present(vc,animated: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotices()
        NoticeTableView.delegate = self
        NoticeTableView.dataSource = self
        
        stopButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopButtonPressed(_:)))
        stopButtonItem.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = stopButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        offNoticeTextColorChange()
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    func fetchNotices(){
        notices.removeAll()
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
                    self.notices.append(notice)
                    if notice.changeSettingTextToRed == true{
                        self.whetherNoticeTextColorChange = true
                    }
                    //時刻で並び替え
                    self.notices.sort { (m1, m2) -> Bool in
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
            self.NoticeTableView.reloadData()
            if self.notices.count > 0{
                self.NoticeTableView.scrollToRow(at: IndexPath(row: self.notices.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    func offNoticeTextColorChange(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).collection("notices").getDocuments{ (snapshots, err) in
            if let err = err{
                print("ノート情報の取得に失敗しました。\(err)")
                return
            }
            for snapshot in snapshots!.documents {
                let documentId = snapshot.documentID
                Firestore.firestore().collection("users").document(email).collection("notices").document(documentId).updateData([
                    "changeSettingTextToRed": false
                ]) { err in
                    if let err = err {
                        print("通知ドキュメントのアップデートに失敗しました。: \(err)")
                        return
                    }
                }
            }
        }
    }
    
    
    @objc func stopButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

//うまく画面遷移できているか
//他のコンテンツへ行くと赤が消える
