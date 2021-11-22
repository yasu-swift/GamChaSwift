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


class LoginViewController: UIViewController {
    let consts = Constants.shared  //Constantsに格納しておいた定数を使うための用意
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
        
        
    }
    
    //取得したcodeを使ってアクセストークンを発行
    func getAccessToken(code: String!) {
        let url = URL(string: consts.baseUrl + "/access_tokens")!
        guard let code = code else { return }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json"
        ]
        let parameters: Parameters = [
            "client_id": consts.clientID,
            "client_secret": consts.clientSecret,
            "code": code
        ]
        print("CODE: \n\(code)")
        //Alamofireでリクエスト
//        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                let token: String? = json["token"].string
//                guard let accessToken = token else { return }
//                self.token = accessToken
//            case .failure(let err):
//                print(err.localizedDescription)
//            }
//        }
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let url = URL(string: consts.oAuthUrl + "?client_id=\(consts.clientID)&scope=\(consts.scopes)")!
        session = ASWebAuthenticationSession(url: url, callbackURLScheme: consts.callbackUrlScheme) {(callback, error) in
            guard error == nil, let successURL = callback else { return }
            let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
            guard let code = queryItems?.filter({ $0.name == "code" }).first?.value else { return } //codeの値だけを取り出す
            self.getAccessToken(code: code)
        }
        session?.presentationContextProvider = self //デリゲートを設定
        session?.prefersEphemeralWebBrowserSession = true //認証セッションと通常のブラウザで閲覧情報やCookieを共有しないように設定。
        session?.start()  //セッションの開始(これがないと認証できない)
    }
    
    
}


//これがあることでボタンを押した時にQiitaのログイン→認証の画面を開ける
extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}
