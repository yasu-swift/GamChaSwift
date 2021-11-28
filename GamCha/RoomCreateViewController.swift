//
//  RoomCreateViewController.swift
//  GamCha
//
//  Created by 高橋康之 on 2021/11/27.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class RoomCreateViewController: UIViewController {
       let consts = Constants.shared
       let okAlert = OkAlert()
       private var token = "" //アクセストークンを格納しておく変数
    
    //ルームタイトル
    @IBOutlet weak var roomTitleTextField: UITextField!
    //人数制限
    @IBOutlet weak var limitUserTextField: UITextField!
    //パスワード設定
    @IBOutlet weak var roomPasswordTextField: UITextField!
    //詳細設定
    @IBOutlet weak var roomBodyTextField: UITextField!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TextViewの見た目をカスタマイズ
        roomBodyTextField.layer.borderColor =  UIColor.placeholderText.cgColor
        roomBodyTextField.layer.borderWidth = 0.5
        roomBodyTextField.layer.cornerRadius = 5.0
        roomBodyTextField.layer.masksToBounds = true
        
        //キーチェーンからアクセストークンを取得して変数に格納
       let keychain = Keychain(service: consts.service)
       guard let token = keychain["access_token"] else { return print("NO TOKEN")}
       self.token = token
        
    }
    
    
    @IBAction func roomCreateButton(_ sender: Any) {
        let room = createRoom()
        roomCreateRequest(roomCreate: room)
        
//        print(comment)
    }


    
    func roomCreateRequest(roomCreate: RoomCreate) {
//        let roomIDString = String(roomID)
        //URL生成
        let url = URL(string: consts.baseUrl + "/rooms/")!
        print(url)
        // Qiita API V2に合わせたパラメータを設定
        let parameters: Parameters = [
            "title": roomCreate.title,
            "body": roomCreate.body,
            "category_id": roomCreate.category_id,
            "userLimit": roomCreate.userLimit
        ]
        //ヘッダにアクセストークンを含める
        let headers :HTTPHeaders = [.authorization(bearerToken: token)]
        //Alamofireで投稿をリクエスト
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                //Success
            case .success(let value):
                let json = JSON(value)
                print(json)
                print("送信できました")
//                self.commentTextField.text = ""
                self.viewDidLoad()
                self.roomBodyTextField.text = ""
                self.roomTitleTextField.text = ""
                self.roomPasswordTextField.text = ""
                //failure
            case .failure(let err):
                print(parameters)
                print("だめでした")
                print(err.localizedDescription)
            }
        }
    }
    //コメント作成
    func createRoom() -> RoomCreate {
        
        //ひとつでも空欄があったらアラート
        if roomTitleTextField.text == "" {
            okAlert.showOkAlert(title: "空欄です", message: "入力して下さい。", viewController: self)
        }
        let limitUserInt = Int(limitUserTextField.text!)
        //PosiingArticle型のオブジェクトを生成して返す。
        let room = RoomCreate(title: roomTitleTextField.text!, body: roomBodyTextField.text!, category_id: 3, userLimit: limitUserInt!)
        print(room)
        return room
    }
    
    //    キーボードを下げる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
