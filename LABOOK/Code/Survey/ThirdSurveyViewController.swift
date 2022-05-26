//
//  ThirdSurveyViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/17.
//

import UIKit
import Firebase
import FirebaseFirestore

class ThirdSurveyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var whetherAnsweredRow = ["未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答"]
    var controllers: [UIViewController] = []
    var csvArray: [String] = []
    var questionArray: [String] = []
    private let cellId = "cellId"
    private var surveyList = [
        "理想の会う頻度は？",
        "実際はどれくらいの頻度で合っている？",
        "LINEは1日何往復が理想？",
        "今どれくらい付き合っている？",
        "記念日やイベントはどうしている？",
        "デートの内容はどちらが提案している?",
        "お泊りの頻度はどれくらい？",
        "相手は十分に愛情表現してくれている？"
    ]
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.textLabel?.text = "(" + String(indexPath.row + 1) + ")" + String(describing: surveyList[indexPath.row])
        
        if let email = Auth.auth().currentUser?.email{
            Firestore.firestore().collection("survey").document("thirdSurvey").collection(surveyList[indexPath.row]).document(email).getDocument {(snapshot, err ) in
                if let err = err {
                    print("ログインユーザーのアンケート情報の取得に失敗しました。\(err)")
                } else {
                    let checkAnsweredLabel = cell.contentView.viewWithTag(1) as! UILabel
                    if (snapshot?.data()) != nil{
                        
                        self.whetherAnsweredRow[indexPath.row] = "回答済"
                        checkAnsweredLabel.textColor = .blue
                    }else{
                        checkAnsweredLabel.text = "未回答"
                        self.whetherAnsweredRow[indexPath.row] = "未回答"
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let VC = storyboard.instantiateViewController(withIdentifier: "SurveyContentViewController") as! SurveyContentViewController
        VC.whetherAnswered = whetherAnsweredRow[indexPath.row]
        VC.tittle = surveyList[indexPath.row]
        VC.questionCount = indexPath.row
        VC.csvFileName = "ThirdSurveyArray"
        VC.surveyName = "thirdSurvey"
        navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBOutlet weak var surveyListTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        csvArray = loadCSV(fileName: "ThirdSurveyArray")
        surveyListTableView.dataSource = self
        surveyListTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        surveyListTableView.reloadData()
    }
    
    func loadCSV(fileName: String) -> [String] {
        let csvBundle = Bundle.main.path(forResource: fileName, ofType: "csv")!
        do {
            let csvData = try String(contentsOfFile: csvBundle,encoding: String.Encoding.utf8)
            let lineChange = csvData.replacingOccurrences(of: "\r", with: "\n")
            csvArray = lineChange.components(separatedBy: "\n")
            csvArray.removeLast()
        } catch {
            print("エラー")
        }
        return csvArray
    }
    
    @IBAction func toFirstPageButton(_ sender: Any) {
        
        let pageViewController = self.parent as! SurveyPageViewController
        let nextIndex0 = 0
        pageViewController.setViewControllers([pageViewController.controllers[nextIndex0]], direction: .reverse, animated: true, completion: nil)
    }
    @IBAction func toSecondPageButton(_ sender: Any) {
        
        let pageViewController = self.parent as! SurveyPageViewController
        let nextIndex1 = 1
        pageViewController.setViewControllers([pageViewController.controllers[nextIndex1]], direction: .reverse, animated: true, completion: nil)
    }
    
    @IBAction func toThirdPageButton(_ sender: Any) {
        
        surveyListTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
    }
    
    @IBAction func toForthPageButton(_ sender: Any) {
        let pageViewController = self.parent as! SurveyPageViewController
        let nextIndex3 = 3
        pageViewController.setViewControllers([pageViewController.controllers[nextIndex3]], direction: .forward, animated: true, completion: nil)
    }
    
}

