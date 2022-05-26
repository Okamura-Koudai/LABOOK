import UIKit
import Firebase
import FirebaseFirestore
import Nuke

private let cellId = "cellId"
class ForthQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let forthQuestionList = ["読んでほしい名前は？","生年月日は？","初めて会った時の印象は？","1番好きなところは？","1番好きな食べ物は？","嫌いな食べ物は？","インドア派？アウトドア派？","今まで1番良かったデートスポットは？","相手を一言で表すと？","1番仲良しな友達はどんな人？","好きな色は？","苦手な色は","子供の頃の将来の夢は？","会っていない時は何してることが多い？","今までしてくれたことで、1番嬉しかったことは？","甘えたい派？甘えられたい派？","これだけは許してほしい自分の短所は？","言いにくいけど、実は直してほしいことは？","たまにしてほしい服装は？","いつか二人で行きたいデートスポットは？","記念日やイベントは全力で楽しみたい派？","1年後の二人はどうなってると思う？","今までの人生で1番頑張ったことは？","来世は男の子がいい？それとも女の子？","感謝の一言をどうぞ！"]
    
    var myForthQuestionAnswer = ["未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答","未回答"]
    
    var numberOfAnswered:Int = 0
    var controllers: [UIViewController] = []
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forthQuestionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = QuestionTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let questionSubject = cell.contentView.viewWithTag(1) as! UILabel
        questionSubject.text =  "(" + String(describing: "\(indexPath.row + 1 )") + ")" + String(describing: forthQuestionList[indexPath.row])
        let myAnswer = cell.contentView.viewWithTag(3) as! UITextView
        myAnswer.text = "未回答" //myFirstQuestionAnswer[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let vc = storyboard.instantiateViewController(withIdentifier: "answerQuestionViewController") as! answerQuestionViewController
        vc.questionName = "forthQuestion"
        vc.transitionSource = "ForthQuestionViewController"
        let cell = QuestionTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        vc.questionSubject = forthQuestionList[indexPath.row]
        let myAnswer = cell.contentView.viewWithTag(3) as! UITextView
        if myAnswer.text != "未回答" {
            vc.myCurrentAnswer = myAnswer.text
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var QuestionTableView: UITableView!
    @IBOutlet weak var answeredCountLabel: UILabel!
    @IBOutlet weak var answeredParcentProgressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsersImage()
        fetchQandAData()
        partnerImageView.layer.cornerRadius = 20
        myImageView.layer.cornerRadius = 20
        QuestionTableView.delegate = self
        QuestionTableView.dataSource = self
        
    }
    
    func fetchQandAData(){
        print("fetchFirstQandADataが呼ばれました。")
        myForthQuestionAnswer.removeAll()
        guard let email = Auth.auth().currentUser?.email else {return}
        forthQuestionList.forEach { question in
            Firestore.firestore().collection("question").document(email).collection("forthQuestion").document(question).getDocument {(snapshot, err ) in
                if let err = err{
                    print("\(question)の情報の取得に失敗しました。\(err)")
                    return
                }else{
                    guard snapshot!.exists else{
                        print("snapshot doesn't exist")
                        self.myForthQuestionAnswer.append("未回答")
                        return
                    }
                    print("snapshot exists")
                    let dic = snapshot?.data()
                    let q = Question.init(dic: dic!)
                    self.myForthQuestionAnswer.append(q.answer)
                    self.numberOfAnswered += 1
                }
                    
                }
            }
            answeredCountLabel.text = "\(numberOfAnswered)/\(forthQuestionList.count)問"
            if numberOfAnswered == 0 {
                answeredParcentProgressView.setProgress(0, animated: false)
            }else{
                answeredParcentProgressView.setProgress(Float(numberOfAnswered/forthQuestionList.count), animated: true)
            }
            QuestionTableView.reloadData()
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
            let url = URL(string: User.profileImageUrl)!
            Nuke.loadImage(with: url, into: self.myImageView)
        }
        //パートナーのイメージも表示
    }
    
    @IBAction func toFirstPageButton(_ sender: Any) {
        
        let pageViewController = self.parent as! QuestionPageViewController
        let nextIndex0 = 0
        pageViewController.setViewControllers([pageViewController.controllers[nextIndex0]], direction: .reverse, animated: true, completion: nil)
    }
    @IBAction func toSecondPageButton(_ sender: Any) {
        
        QuestionTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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


