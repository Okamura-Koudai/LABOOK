//
//  ChatBackgroundColorSettingViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/04/01.
//

import UIKit
import Foundation
import Firebase
import ImageViewer


class ChatBackgroundColorSettingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let cellId = "cellId"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatBackgroundColorList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        let ColorImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let cellImage = UIImage(named: chatBackgroundColorList[indexPath.row])
        ColorImageView.image = cellImage
        return cell
    }
    
    
    let chatBackgroundColorList = ["color1","color2","color3","color4","color5","color6","color7","color8","color9","color10","color11","color12","color13","color14","color15","color16","color17","color18"]
    
    
    @IBOutlet var chatBackgroundColorCollectionTableView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "背景色"
        chatBackgroundColorCollectionTableView.dataSource = self
        chatBackgroundColorCollectionTableView.delegate = self
        chatBackgroundColorCollectionTableView.allowsMultipleSelection = false
        //レイアウト調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let size = view.frame.width / 3
        layout.itemSize = CGSize(width: size - 1, height: size)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        chatBackgroundColorCollectionTableView.collectionViewLayout = layout
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

//        let testIndexpath: IndexPath = IndexPath(row: 1, section: 0)
//        chatBackgroundColorCollectionTableView.selectItem(at: testIndexpath, animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
//
        chatBackgroundColorCollectionTableView.selectItem(at: [0,0],animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
        
        }//これではは初期状態で表示されない？
    
    
    // セルの選択が外れた時に呼び出される
    func collectionView(_ collectionView: UICollectionView,didDeselectItemAt indexPath: IndexPath) {
        
        let unSelectedCell = collectionView.cellForItem(at: indexPath)
        let checkMarkImageView = unSelectedCell?.contentView.viewWithTag(2) as! UIImageView
        checkMarkImageView.layer.cornerRadius = 30 //チェックマーク背景を丸くする
        checkMarkImageView.isHidden = true
    }
    
    
    //cell選択時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        let checkImageView = cell?.contentView.viewWithTag(2) as! UIImageView
        checkImageView.isHidden = false
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("chatRoom").document(email).updateData([
            "chatBackgroundImage": "\(chatBackgroundColorList[indexPath.row])" //UIColor型からString型にとりあえず合わせた
        ]) { err in
            if let err = err {
                print("chatBackgroundColorのアップデートに失敗しました。: \(err)")
            } else {
                print("chatBackgroundColorのアップデートに成功しました。")
            }
        }
    }
    
    
}

