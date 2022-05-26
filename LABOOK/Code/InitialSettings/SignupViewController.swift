//
//  SignupViewController.swift
//  lovenote
//
//  Created by Koudai Okamura on 2022/01/28.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD

class SignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate{
    
    var toolBar:UIToolbar!
    var startDatingDate: Date!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var UserImageView: UIButton!
    @IBOutlet weak var switchSecureTextEntryButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var statrDatingDateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpToolbar()
        UserImageView.layer.cornerRadius = 70
        signUpButton.addTarget(self, action: #selector(tappedSingUpButton), for: .touchUpInside)
        EmailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        statrDatingDateTextField.delegate = self
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor.gray
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    //以下3つ、キーボードに合わせてViewを動かす
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 170
        }
    }

    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func switchSecureTextEntryButton(_ sender: Any) {
        if passwordTextField.isSecureTextEntry == true{
            passwordTextField.isSecureTextEntry.toggle()
            let falsePicture = UIImage(systemName: "eye.circle.fill")!
            switchSecureTextEntryButton.setImage(falsePicture, for: .normal)
            
        }else {
            passwordTextField.isSecureTextEntry.toggle()
            let truePicture = UIImage(systemName: "eye.slash.circle.fill")!
            switchSecureTextEntryButton.setImage(truePicture, for: .normal)
        }
    }
    
    
    @IBAction func UserImageView(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func tappedSingUpButton(){
        self.view.endEditing(true)
        let profileImage = UserImageView.imageView?.image ?? UIImage(named: "C47882BF-DF3B-4EA7-8214-B2C1BB1587FA")
        guard let uploadProfileImage = profileImage?.jpegData(compressionQuality: 0.5) else {return}
        HUD.show(.progress)
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profie_image").child(fileName)
        
        storageRef.putData(uploadProfileImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firebaseへの画像の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            storageRef.downloadURL { (url, err) in
                if let err = err{
                    print("Firebaseからのダウンロードに失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                
                guard let urlString = url?.absoluteString else {return}
                self.createUserToFirebase(profileImageUrl: urlString)
            }
        }
    }
    
    private func createUserToFirebase(profileImageUrl: String){
        guard let email = EmailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
            Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
                if let err = err{
                    print("認証情報の保存に失敗しました。\(err)")
                    HUD.hide()
                    //アラート表示
                    let alert = UIAlertController(title: "登録失敗", message: "Emailまたはパスワードが正しく入力されていません。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                

                guard let username = self.usernameTextField.text else {return}
                let partnerEmail = ""
                let noteFontSize = "20"
                let noteTextSpacingSize = "1"
                let noteFont = "AlNile"
                let docData = [
                    "email": email,
                    "username": username,
                    "createAt": Timestamp(),
                    "profileImageUrl": profileImageUrl,
                    "partnerEmail": partnerEmail,
                    "noteFontSize": noteFontSize,
                    "noteTextSpacingSize": noteTextSpacingSize,
                    "noteFont": noteFont,
                    "startDatingDate": self.startDatingDate!,
                ] as [String : Any]
                
                Firestore.firestore().collection("users").document(email).setData(docData) { (err) in
                    if let err = err {
                        print("Firestoreへの保存に失敗しました。\(err)")
                        HUD.hide()
                        return
                    }
                    print("Firestoreへの保存に成功しました.")
                    HUD.hide()
                    let storyboard: UIStoryboard = self.storyboard!
                    let VC = storyboard.instantiateViewController(withIdentifier: "LinkPartner")
                    self.present(VC, animated: true)
                }
            }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            UserImageView.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[.originalImage] as? UIImage{
            UserImageView.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
        UserImageView.setTitle("", for: .normal)
        UserImageView.imageView?.contentMode = .scaleAspectFill
        UserImageView.contentHorizontalAlignment = .fill
        UserImageView.contentVerticalAlignment = .fill
        UserImageView.clipsToBounds = true
        dismiss(animated:true, completion: nil)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let emailIsEmpty = EmailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernamelIsEmpty = usernameTextField.text?.isEmpty ?? false
        let startDatingDatelIsEmpty = statrDatingDateTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty ||  usernamelIsEmpty || startDatingDatelIsEmpty{
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.gray
        }else{
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.black
        }
        
    }
    
    func setUpToolbar(){
        toolBar = UIToolbar()
        toolBar.sizeToFit()
        let toolBarButton = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(doneButton))
        toolBar.items = [toolBarButton]
        statrDatingDateTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneButton(){
        statrDatingDateTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePikcerView:UIDatePicker = UIDatePicker()
        datePikcerView.datePickerMode = .date
        datePikcerView.preferredDatePickerStyle = .inline
        statrDatingDateTextField.inputView = datePikcerView
        datePikcerView.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker){
        
        let dayInterval = ((Calendar.current.dateComponents([.day], from: sender.date , to: Date())).day!) + 1
        if dayInterval > 0 {
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        startDatingDate = sender.date
        statrDatingDateTextField.text = dateFormatter.string(from: sender.date)
        statrDatingDateTextField.resignFirstResponder()
            
        }else{
            let alert = UIAlertController(title: "未来の日付は入力できません！", message: "本日以前の日付をご入力ください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}



//private func createUserToFirebase(profileImageUrl: String){
//    let alert = UIAlertController(title: "入力されたメールアドレスに認証メールを送信しました。", message: "リンクをクリックし次にお進みください。", preferredStyle: .alert)
//    alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
//    self.present(alert, animated: true, completion: nil)
//    HUD.hide()
//
//    guard let email = EmailTextField.text else { return }
//    guard let password = passwordTextField.text else { return }
//
//    Auth.auth().createUser(withEmail: email, password: password) { (authResult, err) in
//        if let user = authResult?.user {
//            let req = user.createProfileChangeRequest()
//            guard let username = self.usernameTextField.text else {return}
//            req.displayName = username
//            req.commitChanges() { [weak self] error in
//                guard let self = self else { return }
//                if error == nil {
//                    user.sendEmailVerification() { [weak self] error in
//                        guard let self = self else { return }
//                        if error == nil {
//
//                            print("メールアドレス確認済み")
//                            guard let username = self.usernameTextField.text else {return}
//                            let partnerEmail = ""
//                            let noteFontSize = "20"
//                            let noteTextSpacingSize = "1"
//                            let noteFont = "AlNile"
//                            let docData = [
//                                "email": email,
//                                "username": username,
//                                "createAt": Timestamp(),
//                                "profileImageUrl": profileImageUrl,
//                                "partnerEmail": partnerEmail,
//                                "noteFontSize": noteFontSize,
//                                "noteTextSpacingSize": noteTextSpacingSize,
//                                "noteFont": noteFont,
//                                "startDatingDate": self.startDatingDate!,
//                            ] as [String : Any]
//
//                            Firestore.firestore().collection("users").document(email).setData(docData) { (err) in
//                                if let err = err {
//                                    print("Firestoreへの保存に失敗しました。\(err)")
//                                    HUD.hide()
//                                    return
//                                }
//                                print("Firestoreへの保存に成功しました.")
//                                HUD.hide()
//                                let storyboard: UIStoryboard = self.storyboard!
//                                let VC = storyboard.instantiateViewController(withIdentifier: "LinkPartner")
//                                self.present(VC, animated: true)
//                            }
//                        }
//                    }
//
//                } else {
//                    print("メールアドレス未確認")
//                    HUD.hide()
//                    let alert = UIAlertController(title: "登録失敗", message: "Emailまたはパスワードが正しく入力されていません。", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                    return
//                }
//            }
//        }
//    }
//}
//
