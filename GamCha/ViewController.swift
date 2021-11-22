//
//  ViewController.swift
//  GamCha
//
//  Created by 高橋康之 on 2021/11/20.
//

import UIKit
import Firebase
import AuthenticationServices //認証用のモジュール(標準ライブラリ)
import Alamofire
import SwiftyJSON
import KeychainAccess
import FirebaseFirestore

class ViewController: UIViewController {
    let consts = Constants.shared  //Constantsに格納しておいた定数を使うための用意
    var token = ""
    var session: ASWebAuthenticationSession? //Webの認証セッションを入れておく変数
    
    //新規ログインボタン
    @IBOutlet weak var registerButton: UIButton!
    //メールテキストフィールド
    @IBOutlet weak var emailTextField: UITextField!
    //パスワードテキストフィールド
    @IBOutlet weak var passwordTextField: UITextField!
    //ユーザーネームテキストフィールド
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keychain = Keychain(service: consts.service)
        if keychain["access_token"] != nil {
            keychain["access_token"] = nil //keychainに保存されたtokenを削除
        }
        
//        新規ログインボタン初期の状態
        registerButton.isEnabled = false
        registerButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        registerButton.layer.cornerRadius = 10
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
//    キーボードの位置修正
    @objc func showKeyboard(notification: Notification) {
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        guard let keyboardMinY = keyboardFrame?.minY else { return }
        let registerButtonMaxY = registerButton.frame.maxY
        let distance = registerButtonMaxY - keyboardMinY + 20
        
        let transform = CGAffineTransform(translationX: 0, y: -distance)
//        新規ログインボタンの色
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = transform
        })
        
        print("keyboardMinY : ", keyboardMinY, "registerButtonMaxY", registerButtonMaxY)
    }
//    キーボード下げる
    @objc func hideKeyboard() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func registerButtoon(_ sender: Any) {
        handleAuthToFirebase()
        
    }
    //新規ログインボタン
    private func handleAuthToFirebase() {
        
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        //        let username = usernameTextField.text
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("認証情報の取得に失敗しました\(err)")
                return
            }
            print("認証情報の取得に成功しました")
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let name = self.usernameTextField.text else { return }
            
            let docData = ["email": email, "name": name, "createdAt": Timestamp()] as [String : Any]
            
            Firestore.firestore().collection("users").document().setData(docData) {
                (err) in
                if let err = err {
                    print("Firestoreへの保存に失敗しました\(err)")
                    return
                }
                print("Firestoreへ保存しました")
            }
        }
    }
}


//ボタンの部分
extension ViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? true
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
        
        
        print("textField.text:", textField.text)
    }
}
