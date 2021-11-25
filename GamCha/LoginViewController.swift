//
//  LoginViewController.swift
//  GamCha
//
//  Created by 高橋康之 on 2021/11/21.
//

import UIKit
import AuthenticationServices //認証用のモジュール(標準ライブラリ)
import Alamofire
import SwiftyJSON
import KeychainAccess


class LoginViewController: UIViewController, UITextFieldDelegate{
    let consts = Constants.shared //Constantsに格納しておいた定数を使うための用意
    var token = ""
    var session: ASWebAuthenticationSession? //Webの認証セッションを入れておく変数
    //新規ログインボタン
    @IBOutlet weak var loginButton: UIButton!
    //メールテキストフィールド
    @IBOutlet weak var emailTextField: UITextField!
    //パスワードテキストフィールド
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(token)
        
        //        新規ログインボタン初期の状態
//        loginButton.isEnabled = false
//        loginButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
//        loginButton.layer.cornerRadius = 10
//
//        emailTextField.delegate = self
//        passwordTextField.delegate = self
//
//        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //取得したcodeを使ってアクセストークンを発行
    func getAccessToken() {
        let url = URL(string: consts.baseUrl + "/login")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json"
        ]
        let parameters: Parameters = [
            "email": emailTextField.text!,
            "password": passwordTextField.text!
        ]
        //Alamofireでリクエスト
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let token: String? = json["token"].string
                guard let accessToken = token else { return }
                self.token = accessToken
                let keychain = Keychain(service: self.consts.service) //このアプリ用のキーチェーンを生成
                keychain["access_token"] = accessToken //キーを設定して保存
                
                self.transitionToTabBar() //画面遷移
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    @IBAction func loginButton(_ sender: Any) {
        let keychain = Keychain(service: consts.service)
        if keychain["access_token"] != nil {
            token = keychain["access_token"]!
            print("プリント上")
        } else {
            let keychain = Keychain(service: consts.service)
            if keychain["access_token"] != nil {
                token = keychain["access_token"]!
                print("プリント中")
                print(token)
                //            transitionToTabBar() //画面遷移
            } else {
                print("プリント下")
                print(getAccessToken)
                self.getAccessToken()
            }
        }
    }
    
    func transitionToTabBar() {
        let tabBarContorller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarC") as! UITabBarController
        tabBarContorller.modalPresentationStyle = .fullScreen
        present(tabBarContorller, animated: true, completion: nil)
    }
    
    //    キーボードを下げる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //    キーボード下げる
//    @objc func hideKeyboard() {
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
//            self.view.transform = .identity
//        })
//    }
    
    //    キーボードの位置修正
    @objc func showKeyboard(notification: Notification) {
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        guard let keyboardMinY = keyboardFrame?.minY else { return }
        let registerButtonMaxY = loginButton.frame.maxY
        let distance = registerButtonMaxY - keyboardMinY + 20
        
        let transform = CGAffineTransform(translationX: 0, y: -distance)
        //        新規ログインボタンの色
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = transform
        })
        
        print("keyboardMinY : ", keyboardMinY, "registerButtonMaxY", registerButtonMaxY)
    }
}





//これがあることでボタンを押した時にQiitaのログイン→認証の画面を開ける
extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}
