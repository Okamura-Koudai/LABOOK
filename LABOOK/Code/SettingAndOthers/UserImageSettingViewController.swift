//
//  UserImageSettingViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/05/02.
//

import UIKit
import Firebase
import Nuke
import PKHUD

class UserImageSettingViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet weak var chageUserImageButton: UIButton!
    @IBOutlet weak var curentIUsermageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrntUserImage()
        curentIUsermageView.layer.cornerRadius = 75
        chageUserImageButton.layer.cornerRadius = 20
        
    }
    
    
    @IBAction func chageUserImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func fetchCurrntUserImage(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let User = User.init(dic: dic!)
            let url = URL(string: User.profileImageUrl)!
            Nuke.loadImage(with: url, into: self.curentIUsermageView)
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            curentIUsermageView.image = editImage
        }else if let originalImage = info[.originalImage] as? UIImage{
            curentIUsermageView.image = originalImage
        }
        
//        userImageButton.setTitle("", for: .normal)
//        userImageButton.imageView?.contentMode = .scaleAspectFill
//        userImageButton.contentHorizontalAlignment = .fill
//        userImageButton.contentVerticalAlignment = .fill
//        userImageButton.clipsToBounds = true
        dismiss(animated:true, completion: nil)
        
        let profileImage = curentIUsermageView.image ?? UIImage(named: "C47882BF-DF3B-4EA7-8214-B2C1BB1587FA")
        guard let uploadProfileImage = profileImage?.jpegData(compressionQuality: 0.5) else {return}
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profie_image").child(fileName)
        
        storageRef.putData(uploadProfileImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firebaseへの画像の保存に失敗しました。\(err)")
                return
            }
            storageRef.downloadURL { (url, err) in
                if let err = err{
                    print("Firebaseからのダウンロードに失敗しました。\(err)")
                    return
                }
                
                guard let urlString = url?.absoluteString else {return}
                guard let email = Auth.auth().currentUser?.email else {return}
                Firestore.firestore().collection("users").document(email).updateData([
                    "profileImageUrl":urlString
                ]) { err in
                    if let err = err {
                        print("userImageのアップデートに失敗しました。: \(err)")
                        return
                    } else{
                        HUD.flash(.success, delay: 1.0)
                    }
                    
                }
            }
        }
    }
}
//nukeでボタンがわからない場合、イメージViewとは別にボタンを用意すればよい

/*
////ボタン１　チェックマーク表示
@IBAction func button1(_ sender: Any) {
    HUD.flash(.success, delay: 1.0)
    label1.text = "ボタン１の動作"
}

//ボタン２　エラーマーク表示 記述方法が違うバージョン
@IBAction func button2(_ sender: Any) {
    HUD.show(.error)
    HUD.hide(afterDelay: 1.0)
    label1.text = "ボタン２の動作"
}

//ボタン３　ローディング画面の後にチェックマーク
@IBAction func button3(_ sender: Any) {
    label1.text = "ボタン３の動作"
    HUD.show(.progress)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        HUD.flash(.success, delay: 1.0)
    }
}

//ボタン４　コメントを表示させる
@IBAction func button4(_ sender: Any) {
    label1.text = "ボタン４の動作"
    HUD.flash(.label("しばらくお待ちください"), delay: 0.8) { _ in
        HUD.show(.progress)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            HUD.flash(.success, delay: 1.0)
        }
    }
}
}
*/
