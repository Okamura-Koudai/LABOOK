//
//  SurveyPageViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/17.
//

import UIKit
import Firebase

class SurveyPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var settingsButtonItem: UIBarButtonItem!
    // ① PageView上で表示するViewControllerを管理する配列
    var controllers: [UIViewController] = []
     
     override func viewDidLoad() {
         super.viewDidLoad()

         // ②初期化
         self.initPageView()
         settingsButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingsButtonPressed(_:)))
                settingsButtonItem.tintColor = UIColor.black
                noticeButtonItem = UIBarButtonItem(title: "通知", style: .done, target: self, action: #selector(noticeButtonPressed(_:)))
                noticeButtonItem.tintColor = UIColor.black
                self.navigationItem.rightBarButtonItems = [settingsButtonItem,noticeButtonItem]
         self.navigationItem.rightBarButtonItems = [settingsButtonItem,noticeButtonItem]
         self.navigationItem.leftBarButtonItem = datingdDateBottonItem
     }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNoticesData()
    }
    
     // ②初期化（PageViewで表示するViewをセット）
     func initPageView(){
         // PageViewControllerで表示するViewControllerをインスタンス化
         let firstVC = storyboard!.instantiateViewController(withIdentifier: "FirstSurveyViewController") as! FirstSurveyViewController
         let secondVC = storyboard!.instantiateViewController(withIdentifier: "SecondSurveyViewController") as! SecondSurveyViewController
         let ThirdVC = storyboard!.instantiateViewController(withIdentifier: "ThirdSurveyViewController") as! ThirdSurveyViewController
         let ForthVC = storyboard!.instantiateViewController(withIdentifier: "ForthSurveyViewController") as! ForthSurveyViewController


         // インスタンス化したViewControllerを配列に追加
         self.controllers = [ firstVC, secondVC, ThirdVC, ForthVC]

         // 最初に表示するViewControllerを指定する
         setViewControllers([self.controllers[0]],
                            direction: .forward,
                            animated: true,
                            completion: nil)

         // PageViewControllerのDataSourceとの関連付け
         self.dataSource = self
     }
     // スクロールするページ数
     func presentationCount(for pageViewController: UIPageViewController) -> Int {
         return self.controllers.count
     }

     // 左にスワイプした時の処理
     func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
         if let index = self.controllers.firstIndex(of: viewController),
             index < self.controllers.count - 1 {
             return self.controllers[index + 1]
         } else {
             return nil
         }
     }
     
     // 右にスワイプした時の処理
     func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
         if let index = self.controllers.firstIndex(of: viewController),
             index > 0 {
             return self.controllers[index - 1]
         } else {
             return nil
         }
     }
    
    func fetchNoticesData(){
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
    
}
