//
//  ShowViewController.swift
//  GamCha
//
//  Created by 高橋康之 on 2021/11/23.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import Kingfisher

class ShowViewController: UIViewController {
    
    let secitonTitles = ["コメント一覧:"] //セクションのタイトルとして使用
    let consts = Constants.shared
    let okAlert = OkAlert()
    private var token = "" //アクセストークンを格納しておく変数
    var comments: [Comments] = []
    var comment: [CommentPost] = []
    var room: [RoomShow] = []
    
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var showBodyLabel: UILabel!
    @IBOutlet weak var roomShowTableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var pushButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //キーチェーンからアクセストークンを取得して変数に格納
        let keychain = Keychain(service: consts.service)
        guard let token = keychain["access_token"] else { return print("NO TOKEN")}
        self.token = token
        roomShowTableView.dataSource = self
        getCommentsApi()
        getRoomApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCommentsApi()
        getRoomApi()
        print(token)
    }
    
    
    func getRoomApi() {
//        let keychain = Keychain(service: consts.service)
//        guard let accessToken = keychain["access_token"] else { return print("no token") }
        
        let url = URL(string: consts.baseUrl + "/rooms/4")!
        let headers:HTTPHeaders = [
            "content-type": "application/json",
            "Accept": "application/json"]
        //Alamofireでリクエストする
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                //successの時
            case .success(let value):
                self.room = []
                //SwiftyJSONでDecode
                let json = JSON(value).arrayValue //SwiftyJSONでデコード
                print(json)
                
                for room in json {

                    let room = RoomShow(
                        id: room["id"].int!,
                        title: room["title"].string!,
                        body: room["body"].string!,
                        userLimit: room["userLimit"].int!
                    )
                    
                    self.setRoomShow(room: room)
                    
                }
                //failureの時
//                self.reloadData()
            case .failure(let err):
                print("\(err.localizedDescription)です")
            }
        }
    }
    
    
    //User型オブジェクトに含まれる値を、それぞれ、LabelやImageViewに表示させるメソッド
    func setRoomShow(room: RoomShow) {
        //それぞれのLabelに表示
        
        roomTitleLabel.text = room.title
        showBodyLabel.text = room.body
        print("タイトル\(roomTitleLabel.text)ですです")
        print("詳細\(showBodyLabel.text)ですです")
        
    }
    
    
    
    
    
    //テーブルビューに表示するための物
    func getCommentsApi() {
        let url = URL(string: consts.baseUrl + "/rooms/4/comments")!
        let headers:HTTPHeaders = [
            "content-type": "application/json",
            "Accept": "application/json"]
        //Alamofireでリクエストする
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                //successの時
            case .success(let value):
                self.comments = []
                //SwiftyJSONでDecode
                let json = JSON(value).arrayValue //SwiftyJSONでデコード
//                print(json)
                for comment in json {
                    let comment = Comments(
                        name: comment["name"].string!,
                        user_id: comment["user_id"].int!,
                        body: comment["body"].string!,
                        room_id: comment["room_id"].int!
                    )
//                    print(room)
                    self.comments.append(comment)
                }
                //failureの時
                self.roomShowTableView.reloadData()
            case .failure(let err):
                print("\(err.localizedDescription)です")
            }
        }
    }
    
    
    
    
    @IBAction func shareButton(_ sender: Any) {
        // 共有する項目
        let shareText = "#急募です。本当に急募です！！"
        let shareWebsite = NSURL(string: consts.baseUrl + "/rooms/4/comments")!
        let activityItems = [shareText, shareWebsite] as [Any]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
         // 使用しないアクティビティタイプ
         let excludedActivityTypes = [
         UIActivity.ActivityType.postToFacebook,
         UIActivity.ActivityType.message,
         UIActivity.ActivityType.saveToCameraRoll,
         UIActivity.ActivityType.print
         ]
         activityVC.excludedActivityTypes = excludedActivityTypes
        // UIActivityViewControllerを表示
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    @IBAction func pushButton(_ sender: Any) {
        
        let comment = createComment()
        postRequest(comment: comment)
//        print(comment)
    }
    
    
    func postRequest(comment: CommentPost) {
        //URL生成
        let url = URL(string: "http://localhost/api/rooms/4/comments")!
        // Qiita API V2に合わせたパラメータを設定
        let parameters: Parameters = [
            "body": comment.body,
            "room_id": comment.room_id,
            "name": comment.name,
            "user_id": comment.user_id
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
                print("たぶん送信できました")
                //failure
            case .failure(let err):
                print(parameters)
                print("だめでした")
                print(err.localizedDescription)
            }
        }
    }
    //コメント作成
    func createComment() -> CommentPost {
        
        //ひとつでも空欄があったらアラート
        if commentTextField.text == "" {
            okAlert.showOkAlert(title: "空欄です", message: "入力して下さい。", viewController: self)
        }
        //PosiingArticle型のオブジェクトを生成して返す。
        let comment = CommentPost(body: commentTextField.text!, room_id: 4, name: "田中さん", user_id: 5)
//        print(comment)
        return comment
    }
    
    //    キーボードを下げる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}


extension ShowViewController: UITableViewDataSource {
    //セクション中のセルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    //セルのLabelに記事のタイトルを表示(限定共有のものには[限定共有]と先頭につけるよう場合分け)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Storyboardで設定したセルのIdentifierを指定。
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath as IndexPath)
        tableView.rowHeight = 130
        
        //ラベルオブジェクトを作る
        let labelName = cell.viewWithTag(1) as! UILabel
        let labelComment = cell.viewWithTag(2) as! UILabel
        //ラベルに表示する文字列を設定
        labelName.text = comments[indexPath.row].name
        labelComment.text = comments[indexPath.row].body
        
        return cell
    }
    //セクションの数はセクションのタイトルの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return secitonTitles.count
    }
    //セクションのタイトルを設定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return secitonTitles[section]
    }
}
