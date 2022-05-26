//
//  QandAViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/02.
//
import Foundation
import UIKit
import MessageUI

private let cellId = "cellId"

class QandAViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UISearchBarDelegate {
    
    private var QandAList: [String] = [
        "A1", "A2", "A3", "A4", "A5",
        "B1", "B2", "B3", "B4", "B5",
        "C1", "C2", "C3", "C4", "C5",
        "D1", "D2", "D3", "D4", "D5",
        "E1", "E2", "E3", "E4", "E5"
    ]
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QandAList.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") ??
        UITableViewCell(style: .default, reuseIdentifier: "cellId")
        cell.textLabel?.text = QandAList[indexPath.row]
        return cell
    }
    
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let VC = storyboard.instantiateViewController(withIdentifier: "QandAPageViewController") as! QandAPageViewController
        VC.QuestionTittle = QandAList[indexPath.row]
        navigationController?.pushViewController(VC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBOutlet weak var inquiryButton: UIButton!
    @IBOutlet weak var QandASerchBar: UISearchBar!
    @IBOutlet weak var QandAListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inquiryButton.layer.cornerRadius = 20
        QandAListTableView.dataSource = self
        QandAListTableView.delegate = self
        QandASerchBar.delegate = self
    }
    
    //SeachBarに入力された文字列を取得を含むListを残す
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String){
        var seachedList: [String] = []
        if QandASerchBar.text == "" {
            QandAList = [
                "A1", "A2", "A3", "A4", "A5",
                "B1", "B2", "B3", "B4", "B5",
                "C1", "C2", "C3", "C4", "C5",
                "D1", "D2", "D3", "D4", "D5",
                "E1", "E2", "E3", "E4", "E5"
            ]
        }else {
            QandAList.forEach({
                if $0.contains(searchText) {
                    seachedList.insert($0, at: 0)
                }
            })
            QandAList = seachedList
        }
        QandAListTableView.reloadData()
    }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    //検索外タッチでキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func inquiryButton(_ sender: Any) {
        // メールを送信できるかどうかの確認
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        // インスタンスの作成とデリゲートの委託
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        
        // 宛先の設定（開発者側のアドレス）
        let toRecipients = ["koudaisuper@icloud.com"] //とりあえず個人koudaisuper@icloud.com
        
        // 件名と宛先の表示
        mailViewController.setSubject("LABOOKへのお問い合わせ")
        mailViewController.setToRecipients(toRecipients)
        mailViewController.setMessageBody("LABOOKをご利用いただき、ありがとうございます。下記の項目をご確認の上、お問い合わせをよろしくお願いいたします。\n・よくある質問を確認した。\n・アプリのバージョンは最新である。", isHTML: false)
        
        // mailViewControllerの反映（メール内容の反映）
        self.present(mailViewController, animated: true, completion: nil)
    }
    // メール機能終了処理
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // メールの結果で条件分岐
        switch result {
            
            // キャンセルの場合
        case .cancelled:
            print("Email Send Cancelled")
            break
            
            // 下書き保存の場合
        case .saved:
            print("Email Saved as a Draft")
            break
            
            // 送信成功の場合
        case .sent:
            print("Email Sent Successfully")
            break
            
            // 送信失敗の場合
        case .failed:
            print("Email Send Failed")
            break
        default:
            break
        }
        
        //メールを閉じる
        controller.dismiss(animated: true, completion: nil)
    }
    
}


//タップした瞬間だけ背景色変化させたい　tableView.deselectRow(at: indexPath, animated: true)
