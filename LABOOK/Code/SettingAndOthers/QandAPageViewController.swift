//
//  QandAPageViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/02.
//

import UIKit

class QandAPageViewController: UIViewController {
    
    var QuestionTittle: String!
    @IBOutlet weak var questionTittleTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        questionTittleTextView.text = QuestionTittle
        
        switch questionTittleTextView.text {
        case "A1":
            answerTextView.text = "A1に対する回答"
        case "A2":
            answerTextView.text = "A2に対する回答"
        case "A3":
            answerTextView.text = "A3に対する回答"
        case "A4":
            answerTextView.text = "A4に対する回答"
        case "A5":
            answerTextView.text = "A5に対する回答"
        default:
            answerTextView.text = "申し訳ありません。ただいま準備中です。"
        }
    }
    

}
