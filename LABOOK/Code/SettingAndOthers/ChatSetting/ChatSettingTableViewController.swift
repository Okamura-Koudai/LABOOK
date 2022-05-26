//
//  ChatSettingTableViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/31.
//

import UIKit
import Firebase
import FirebaseFirestore
import Nuke

class ChatSettingTableViewController: UITableViewController {
    
    @IBOutlet weak var previewChatBackgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewChatBackgroundImageView.layer.borderColor = UIColor.black.cgColor
        previewChatBackgroundImageView.layer.borderWidth = 2
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fecthChatBackgroundImage()
    }
    
    func fecthChatBackgroundImage(){
      
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
                self.previewChatBackgroundImageView.image = image
                
            } else { // もしChatBackGroundImagePreviewImageViewが長かったら、それはURL
                let url = URL(string: ChatRoom.chatBackgroundImage)
                print("背景写真URL:",url!)
                Nuke.loadImage(with: url, into: self.previewChatBackgroundImageView)
            }
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
