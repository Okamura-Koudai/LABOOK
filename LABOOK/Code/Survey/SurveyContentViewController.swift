import UIKit
import Charts
import Firebase
import FirebaseFirestore

class SurveyContentViewController: UIViewController {
    
    var surveyName: String!
    var csvFileName: String!
    var whetherAnswered :String!
    var tittle: String!
    var csvArray: [String] = []
    var questionArray: [String] = []
    var questionCount: Int!
    var countAll : Int! = 0
    var count1: Int! = 0
    var count2: Int! = 0
    var count3: Int! = 0
    var count4: Int! = 0
    var count5: Int! = 0
    
    @IBOutlet weak var pieChartsView: PieChartView!
    @IBOutlet weak var resultCoverView: PieChartView!
    @IBOutlet weak var surveyButton1: UIButton!
    @IBOutlet weak var surveyButton2: UIButton!
    @IBOutlet weak var surveyButton3: UIButton!
    @IBOutlet weak var surveyButton4: UIButton!
    @IBOutlet weak var numberOfAnswerLabel: UILabel!
    @IBOutlet weak var surveyButton5: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = tittle
        
        surveyButton1.layer.cornerRadius = 5
        surveyButton2.layer.cornerRadius = 5
        surveyButton3.layer.cornerRadius = 5
        surveyButton4.layer.cornerRadius = 5
        surveyButton5.layer.cornerRadius = 5

        //選択肢表示
        csvArray = loadCSV(fileName: csvFileName)
        questionArray = csvArray[questionCount].components(separatedBy: ",")
        surveyButton1.setTitle("1：" + questionArray[1], for: .normal)
        surveyButton2.setTitle("2：" + questionArray[2], for: .normal)
        surveyButton3.setTitle("3：" + questionArray[3], for: .normal)
        surveyButton4.setTitle("4：" + questionArray[4], for: .normal)
        surveyButton5.setTitle("5：" + questionArray[5], for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(whetherAnswered!)//回答済みなのに未回答が出た//
        if whetherAnswered == "回答済"{
            showResult()
        }
    }
    
    @IBAction func surveyButton(_ sender: UIButton) {
        
        if self.surveyButton1.backgroundColor == .green || self.surveyButton2.backgroundColor == .yellow {
            let alert = UIAlertController(title: "このアンケートは既に回答済みです。", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.surveyButton1.backgroundColor = .green
        self.surveyButton2.backgroundColor = .yellow
        self.surveyButton3.backgroundColor = .orange
        self.surveyButton4.backgroundColor = .cyan
        self.surveyButton5.backgroundColor = .red
        
        //①データ保存
        let answerNumber = sender.tag
        guard let tittle = tittle else {return}
        guard let email = Auth.auth().currentUser?.email else {return}
        let docData = [
            "email" : email,
            "answerNumber" : "\(answerNumber)"
        ] as [String : Any]
        
        Firestore.firestore().collection("survey").document(surveyName).collection(tittle).document(email).setData(docData) { (err) in
            if let err = err{
                print("Firestoreへのアンケート結果の保存に失敗しました。\(err)")
                return
            }
        }
       //②全体でのデータ集計
        Firestore.firestore().collection("survey").document(self.surveyName).collection(tittle).getDocuments() {(snapshots, err) in
            if let err = err{
                print("表示中のタイトルのアンケート情報を取得できませんでした。: \(err)")
                return
            }
            for snapshot in snapshots!.documents {
                let dic = snapshot.data()
                let survey = Survey(dic: dic)
                let answerTag = Int(survey.answerNumber)

                switch answerTag {
                case 1:
                    self.countAll += 1
                    self.count1 += 1
                case 2:
                    self.countAll += 1
                    self.count2 += 1
                case 3:
                    self.countAll += 1
                    self.count3 += 1
                case 4:
                    self.countAll += 1
                    self.count4 += 1
                case 5:
                    self.countAll += 1
                    self.count5 += 1
                default:
                    print("未回答のアンケート")
                }

            }
            
            //③データ表示
            let numberOfAnswerText = "現在の回答人数：\(self.countAll!)人"
            self.numberOfAnswerLabel.text = numberOfAnswerText
            self.numberOfAnswerLabel.isHidden = false

            let valueOfLabel1 = Double(self.count1)/Double(self.countAll)*100
            let valueOfLabel2 = Double(self.count2)/Double(self.countAll)*100
            let valueOfLabel3 = Double(self.count3)/Double(self.countAll)*100
            let valueOfLabel4 = Double(self.count4)/Double(self.countAll)*100
            let valueOfLabel5 = Double(self.count5)/Double(self.countAll)*100
            
            self.pieChartsView.centerText = "回答済み"
            let dataEntries = [
                PieChartDataEntry(value: valueOfLabel1, label: "1"),
                PieChartDataEntry(value: valueOfLabel2, label: "2"),
                PieChartDataEntry(value: valueOfLabel3, label: "3"),
                PieChartDataEntry(value: valueOfLabel4, label: "4"),
                PieChartDataEntry(value: valueOfLabel5, label: "5"),
            ]

            // データ表示に関する設定
            let dataSet = PieChartDataSet(entries: dataEntries, label: "質問：" + tittle)
            dataSet.colors = ChartColorTemplates.vordiplom()
            dataSet.valueTextColor = UIColor.black
            dataSet.entryLabelColor = UIColor.black
            self.pieChartsView.data = PieChartData(dataSet: dataSet)
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.maximumFractionDigits = 2
            formatter.multiplier = 1.0
            self.pieChartsView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
            self.pieChartsView.usePercentValuesEnabled = true
            self.pieChartsView.animate(xAxisDuration: 1, yAxisDuration: 1)
            self.view.addSubview(self.pieChartsView)
        }
    }
    
    //ユーザーが回答済みのアンケートを開いたときの処理
    func showResult(){
        
        self.surveyButton1.backgroundColor = .green
        self.surveyButton2.backgroundColor = .yellow
        self.surveyButton3.backgroundColor = .orange
        self.surveyButton4.backgroundColor = .cyan
        self.surveyButton5.backgroundColor = .red
        
        Firestore.firestore().collection("survey").document(self.surveyName).collection(tittle).getDocuments() {(snapshots, err) in
            if let err = err{
                print("表示中のタイトルのアンケート情報を取得できませんでした。: \(err)")
                return
            }
            
            for snapshot in snapshots!.documents {
                let dic = snapshot.data()
                let survey = Survey(dic: dic)
                let answerTag = Int(survey.answerNumber)
                
                switch answerTag {
                case 1:
                    self.countAll += 1
                    self.count1 += 1
                case 2:
                    self.countAll += 1
                    self.count2 += 1
                case 3:
                    self.countAll += 1
                    self.count3 += 1
                case 4:
                    self.countAll += 1
                    self.count4 += 1
                case 5:
                    self.countAll += 1
                    self.count5 += 1
                default:
                    print("未回答のアンケート")
                }
                
            }
            
            let numberOfAnswerText = "現在の回答人数：\(self.countAll!)人"
            self.numberOfAnswerLabel.text = numberOfAnswerText
            self.numberOfAnswerLabel.isHidden = false
            
            let valueOfLabel1 = Double(self.count1)/Double(self.countAll)*100
            let valueOfLabel2 = Double(self.count2)/Double(self.countAll)*100
            let valueOfLabel3 = Double(self.count3)/Double(self.countAll)*100
            let valueOfLabel4 = Double(self.count4)/Double(self.countAll)*100
            let valueOfLabel5 = Double(self.count5)/Double(self.countAll)*100
            
            self.pieChartsView.centerText = "回答済み"
            let dataEntries = [
                PieChartDataEntry(value: valueOfLabel1, label: "1"),
                PieChartDataEntry(value: valueOfLabel2, label: "2"),
                PieChartDataEntry(value: valueOfLabel3, label: "3"),
                PieChartDataEntry(value: valueOfLabel4, label: "4"),
                PieChartDataEntry(value: valueOfLabel5, label: "5"),
            ]
            
            // データ表示に関する設定
            let dataSet = PieChartDataSet(entries: dataEntries, label: "質問：" + self.tittle)
            dataSet.colors = ChartColorTemplates.vordiplom()
            dataSet.valueTextColor = UIColor.black
            dataSet.entryLabelColor = UIColor.black
            self.pieChartsView.data = PieChartData(dataSet: dataSet)
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.maximumFractionDigits = 2
            formatter.multiplier = 1.0
            self.pieChartsView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
            self.pieChartsView.usePercentValuesEnabled = true
            self.pieChartsView.animate(xAxisDuration: 1, yAxisDuration: 1)
            self.view.addSubview(self.pieChartsView)
        }
    }
    
    func loadCSV(fileName: String) -> [String] {
        let csvBundle = Bundle.main.path(forResource: fileName, ofType: "csv")!
        do {
            let csvData = try String(contentsOfFile: csvBundle,encoding: String.Encoding.utf8)
            let lineChange = csvData.replacingOccurrences(of: "\r", with: "\n")
            csvArray = lineChange.components(separatedBy: "\n")
            csvArray.removeLast()
        } catch {
            print("CSVの読み込みエラーが発生しています。")
        }
        return csvArray
    }
}
