import UIKit
import Firebase

class UserEmailSettingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentEmailTextField: UITextField!
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var changeEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeEmailButton.layer.cornerRadius = 20
        newEmailTextField.delegate = self
        fetchCurrentEmail()
    }
    
    @IBAction func changeEmailButton(_ sender: Any) {
        newEmailTextField.resignFirstResponder()
        if let newUserEmail = newEmailTextField.text {
            //画面遷移
        }
    }
    
    @IBAction func toChangePasswordButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let vc = storyboard.instantiateViewController(withIdentifier: "LogoutViewController")
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav,animated: true)
    }
    
    func fetchCurrentEmail(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Firestore.firestore().collection("users").document(email).getDocument { (snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let user = User.init(dic: dic!)
            self.currentEmailTextField.text = user.email
            
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let currentEmailIsEmpty = currentEmailTextField.text?.isEmpty ?? false
        let newEmailIsEmpty = newEmailTextField.text?.isEmpty ?? false
        
        if currentEmailIsEmpty || newEmailIsEmpty {
            changeEmailButton.isEnabled = false
        }else{
            changeEmailButton.isEnabled = true
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
