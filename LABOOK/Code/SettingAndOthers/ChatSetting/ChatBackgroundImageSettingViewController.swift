//
//  ChatBackgroundImageSettingViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/31.
//

import UIKit
import Firebase
import FirebaseFirestore
import Nuke


private let cellId = "cellId"

class ChatBackgroundImageSettingViewController: UIViewController, UITableViewDataSource , UITableViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let chatBackgroundImageSettingList = ["背景色で設定","アルバムから設定","カメラで設定"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatBackgroundImageSettingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ChatBackgroundImageSettingTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = String(describing: chatBackgroundImageSettingList[indexPath.row])
        cell.contentView.isUserInteractionEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch indexPath.row {
        case 0: //背景色
            let storyboard: UIStoryboard = self.storyboard!
            let vc = storyboard.instantiateViewController(withIdentifier: "ChatBackgroundColorSettingViewController") as! ChatBackgroundColorSettingViewController
            self.navigationController?.pushViewController(vc, animated: true)

        case 1: //アルバム
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
            else {
                print("photoLibrary not available.")
            }
        case 2: //カメラ
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
            else {
                print("Camera not available.")
            }
        default:
            print("err")
        }
        
        //        let storyboard: UIStoryboard = self.storyboard!
        //        let VC = storyboard.instantiateViewController(withIdentifier: "QandAPageViewController") as! QandAPageViewController
        //        VC.QuestionTittle = QandAList[indexPath.row]
        //        navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBOutlet weak var ChatBackGroundImagePreviewImageView: UIImageView!
    @IBOutlet weak var ChatBackgroundImageSettingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChatBackgroundImageSettingTableView.dataSource = self
        ChatBackgroundImageSettingTableView.delegate = self
        fecthChatBackgroundImage()
        ChatBackGroundImagePreviewImageView.layer.borderColor = UIColor.black.cgColor
        ChatBackGroundImagePreviewImageView.layer.borderWidth = 3
        
    }
    
    func  fecthChatBackgroundImage(){
        
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("chatRoom").document(email).getDocument { (snapshot, err) in
            if let err = err{
                print("チャット情報の取得に失敗しました。\(err)")
                return
        }
        let dic = snapshot?.data()
        let ChatRoom = ChatRoom.init(dic: dic!)
        let chatBackgroundImage = ChatRoom.chatBackgroundImage
        // もしChatBackGroundImagePreviewImageViewが短かったら、それはアセット画像
        let chatBackgroundImageLength = chatBackgroundImage.count
            if chatBackgroundImageLength <= 10 {
                
                let image = UIImage(named: chatBackgroundImage)
                self.ChatBackGroundImagePreviewImageView.image = image
        
            } else { // もしChatBackGroundImagePreviewImageViewが長かったら、それはURL
                let url = URL(string: ChatRoom.chatBackgroundImage)
                Nuke.loadImage(with: url, into: self.ChatBackGroundImagePreviewImageView)
            }
        
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            ChatBackGroundImagePreviewImageView.image = selectedImage
            
            //画像の保存
            //let profileImage = UserImageView.imageView?.image ?? UIImage(named: "C47882BF-DF3B-4EA7-8214-B2C1BB1587FA") //デフォルトのプロフィール画像
            //guard let profileImage = UserImageView.imageView?.image else {return}
            guard let uploadSelectedImageImage = selectedImage.jpegData(compressionQuality: 0.5) else {return}
            let fileName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("chatBackground_image").child(fileName)
            
            storageRef.putData(uploadSelectedImageImage, metadata: nil) { (metadata, err) in
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
                    Firestore.firestore().collection("chatRoom").document(email).updateData([
                        "chatBackgroundImage": urlString
                    ]) { err in
                        if let err = err {
                            print("chatBackgroundImageUrlのアップデートに失敗しました。: \(err)")
                        } else {
                            print("chatBackgroundImageUrlのアップデートに成功しました。")
                        }
                    }
                }
            }
            
            
        }
        self.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    
}
