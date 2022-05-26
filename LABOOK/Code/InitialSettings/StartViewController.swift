//
//  LoginViewController.swift
//  lovenote
//
//  Created by Koudai Okamura on 2022/01/24.
//

import UIKit
import Firebase

class StartViewController: UIViewController {
    
    @IBOutlet weak var StartLabel: UILabel!
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termsOfUseButton.layer.cornerRadius = 20
        privacyPolicyButton.layer.cornerRadius = 20
        
    }
    
    
    @IBAction func toInquiryButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let VC = storyboard.instantiateViewController(withIdentifier: "QandAViewController")
        let nav = UINavigationController(rootViewController: VC)
        self.present(nav,animated: true)
    }
    
    @IBAction func termsOfUseButton(_ sender: Any) {
        let storyboard1: UIStoryboard = self.storyboard!
        let VC1 = storyboard1.instantiateViewController(withIdentifier: "termsOfUse")
        let nav1 = UINavigationController(rootViewController: VC1)
        self.present(nav1,animated: true)
    }
    
    
    @IBAction func privacyPolicyButton(_ sender: Any) {
        let storyboard2: UIStoryboard = self.storyboard!
        let VC2 = storyboard2.instantiateViewController(withIdentifier: "PrivacyPolicy")
        let nav2 = UINavigationController(rootViewController: VC2)
        self.present(nav2,animated: true)
    }
    
}


