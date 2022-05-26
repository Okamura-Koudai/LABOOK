//
//  SecondQuestionViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/02/27.
//
import UIKit
import Firebase
import FirebaseFirestore
import Nuke
import PKHUD

private let cellId = "cellId"

class FirstQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var firstQuestionList = ["読んでほしい名前は？","生年月日は？","初めて会った時の印象は？","1番好きなところは？","1番好きな食べ物は？","嫌いな食べ物は？","インドア派？アウトドア派？","今まで1番良かったデートスポットは？","相手を一言で表すと？","1番仲良しな友達はどんな人？","好きな色は？","苦手な色は","子供の頃の将来の夢は？","会っていない時は何してることが多い？","今までしてくれたことで、1番嬉しかったことは？","甘えたい派？甘えられたい派？","これだけは許してほしい自分の短所は？","言いにくいけど、実は直してほしいことは？","たまにしてほしい服装は？","いつか二人で行きたいデートスポットは？","記念日やイベントは全力で楽しみたい派？","1年後の二人はどうなってると思う？","今までの人生で1番頑張ったことは？","来世は男の子がいい？それとも女の子？","感謝の一言をどうぞ！"]
    
    var myFirstQuestionAnswer = [String]()
    var partnerQuestionAnswer = [String]()
    var numberOfAnswered:Int = 0
    var controllers: [UIViewController] = []
    
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var QuestionTableView: UITableView!
    @IBOutlet weak var answeredCountLabel: UILabel!
    @IBOutlet weak var answeredParcentProgressView: UIProgressView!
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firstQuestionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = QuestionTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let questionSubject = cell.contentView.viewWithTag(1) as! UILabel
        questionSubject.text =  "(" + String(describing: "\(indexPath.row + 1 )") + ")" + String(describing: firstQuestionList[indexPath.row])
        let myAnswer = cell.contentView.viewWithTag(3) as! UITextView
        myAnswer.layer.cornerRadius = 10
        let partnerAnswer = cell.contentView.viewWithTag(2) as! UITextView
        partnerAnswer.layer.cornerRadius = 10
        myAnswer.isUserInteractionEnabled = false
        partnerAnswer.isUserInteractionEnabled = false
        
        //回答データ読み込み前
        if myFirstQuestionAnswer.count == 0 || partnerQuestionAnswer.count == 0{
            myAnswer.text = "読み込み中"
            partnerAnswer.text = "読み込み中"
        //回答データ読み込み後
        }else{
            myAnswer.text = myFirstQuestionAnswer[indexPath.row]
            //1.両者の配列の文字が未回答以外のとき
            if myFirstQuestionAnswer[indexPath.row] != "未回答" && partnerQuestionAnswer[indexPath.row] != "未回答" {
                partnerAnswer.text = partnerQuestionAnswer[indexPath.row]
                partnerAnswer.backgroundColor = .green

                //2.自分の配列だけが未回答以外のとき
            }else if myFirstQuestionAnswer[indexPath.row] != "未回答" && partnerQuestionAnswer[indexPath.row] == "未回答"{
                partnerAnswer.text = "相手の回答を待ちましょう。"
                partnerAnswer.backgroundColor = .systemOrange

                //3.相手の配列だけが未回答以外のとき、または両方未回答
            }else if myFirstQuestionAnswer[indexPath.row] == "未回答" && partnerQuestionAnswer[indexPath.row] != "未回答"{
                partnerAnswer.text = "回答済み\n両者回答すると公開されます。"
                partnerAnswer.backgroundColor = .yellow

                //4.両方未回答
            }else if myFirstQuestionAnswer[indexPath.row] == "未回答" && partnerQuestionAnswer[indexPath.row] == "未回答"{
                partnerAnswer.text = "未回答"
                partnerAnswer.backgroundColor = .lightGray
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let vc = storyboard.instantiateViewController(withIdentifier: "answerQuestionViewController") as! answerQuestionViewController
        vc.questionName = "firstQuestion"
        vc.transitionSource = "FirstQuestionViewController"
        let cell = QuestionTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        vc.questionSubject = firstQuestionList[indexPath.row]
        let myAnswer = cell.contentView.viewWithTag(3) as! UITextView
        vc.myCurrentAnswer = myAnswer.text
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        HUD.show(.progress)
        fetchQandAData()
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.QuestionTableView.delegate = self
        self.QuestionTableView.dataSource = self
        partnerImageView.layer.cornerRadius = 20
        myImageView.layer.cornerRadius = 20
        fetchUsersImage()
       
    }
    
    func fetchQandAData(){
        myFirstQuestionAnswer.removeAll()
        partnerQuestionAnswer.removeAll()
        numberOfAnswered = 0
        guard let email = Auth.auth().currentUser?.email else {return}
        firstQuestionList.forEach { question in
            Firestore.firestore().collection("question").document(email).collection("firstQuestion").document(question).getDocument {(snapshot, err ) in
                if let err = err{
                    print("\(question)の情報の取得に失敗しました。\(err)")
                }else{
                    if snapshot?.data() != nil{
                        let dic = snapshot?.data()
                        let q = Question.init(dic: dic!)
                        self.myFirstQuestionAnswer.append(q.answer)
                        self.numberOfAnswered += 1
                    }else{
                        self.myFirstQuestionAnswer.append("未回答")
                    }
                   
                }
            }
        }
        self.addPartnerAnswer(email: email) //同期処理外？addSnapを使って組み込む？
    }
    
    func fetchUsersImage(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let User = User.init(dic: dic!)
            let partnerEmail = User.partnerEmail
            let url = URL(string: User.profileImageUrl)!
            Nuke.loadImage(with: url, into: self.myImageView)
            
            Firestore.firestore().collection("users").document(partnerEmail).getDocument {(snapshot, err ) in
                if let err = err{
                    print("パートナーユーザー情報の取得に失敗しました。\(err)")
                    return
                }
                let dic = snapshot?.data()
                let Partner = Partner.init(dic: dic!)
                let url = URL(string: Partner.profileImageUrl)!
                Nuke.loadImage(with: url, into: self.partnerImageView)
            }
        }
    }
    
    func addPartnerAnswer(email :String){
        //firstQuestionListのループ処理よりパートナーの回答の配列をそれぞれ取得しpartnerQuestionAnswerにappend
        Firestore.firestore().collection("users").document(email).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let User = User.init(dic: dic!)
            let partnerEmail = User.partnerEmail
            
            self.firstQuestionList.forEach { question in
                Firestore.firestore().collection("question").document(partnerEmail).collection("firstQuestion").document(question).getDocument {(snapshot, err ) in
                    if let err = err{
                        print("\(question)の情報の取得に失敗しました。\(err)")
                    }else{
                        
                        if snapshot?.data() != nil{
                            let dic = snapshot?.data()
                            let q = Question.init(dic: dic!)
                            self.partnerQuestionAnswer.append(q.answer)
                        }else{
                            self.partnerQuestionAnswer.append("未回答")
                        }
                        
                    }
                }
            }
            let progressValue = (Float(self.numberOfAnswered)/Float(self.firstQuestionList.count))
            self.answeredCountLabel.text = "\(self.numberOfAnswered)/\(self.firstQuestionList.count)問"
            self.answeredParcentProgressView.setProgress(progressValue, animated: true)
            self.QuestionTableView.reloadData()
            HUD.hide()
        }
        
    }
    
    @IBAction func toFirstPageButton(_ sender: Any) {
        QuestionTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    @IBAction func toSecondPageButton(_ sender: Any) {
        
        let pageViewController = self.parent as! QuestionPageViewController
        let nextIndex1 = 1
        pageViewController.setViewControllers([pageViewController.controllers[nextIndex1]], direction: .forward, animated: true, completion: nil)
    }
    
    @IBAction func toThirdPageButton(_ sender: Any) {
        let pageViewController = self.parent as! QuestionPageViewController
        let nextIndex2 = 2
        pageViewController.setViewControllers([pageViewController.controllers[nextIndex2]], direction: .forward, animated: true, completion: nil)
    }
    
    @IBAction func toForthPageButton(_ sender: Any) {
        let pageViewController = self.parent as! QuestionPageViewController
        let nextIndex3 = 3
        pageViewController.setViewControllers([pageViewController.controllers[nextIndex3]], direction: .forward, animated: true, completion: nil)
    }
    
}
