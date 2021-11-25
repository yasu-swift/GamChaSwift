//
//  HomeViewController.swift
//  GamCha
//
//  Created by 高橋康之 on 2021/11/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import Kingfisher

class HomeViewController: UIViewController {
    @IBOutlet weak var roomsTableView: UITableView! //部屋一覧を表示するTableView
    
    let secitonTitles = ["部屋一覧:"] //セクションのタイトルとして使用
    let consts = Constants.shared
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomsTableView.dataSource = self
        getRoomsApi()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRoomsApi()
        //        print("\(getRoomsApi())テスト")
    }
    
    
    func getRoomsApi() {
        let url = URL(string: consts.baseUrl + "/rooms")!
        let headers:HTTPHeaders = [
            "content-type": "application/json",
            "Accept": "application/json"]
        //Alamofireでリクエストする
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                //successの時
            case .success(let value):
                self.rooms = []
                //SwiftyJSONでDecode
                let json = JSON(value).arrayValue //SwiftyJSONでデコード
//                print(json)
                for room in json {
                    let room = Room(
                        title: room["title"].string!,
                        body: room["body"].string!,
                        // joinUser: (room["joinUser"].int)!,
                        category_id: room["category_id"].int!,
                        userLimit: room["userLimit"].int!,
                        updated_at: room["updated_at"].string!
                    )
//                    print(room)
                    self.rooms.append(room)
                }
                //failureの時
                self.roomsTableView.reloadData()
            case .failure(let err):
                print("\(err.localizedDescription)です")
            }
        }
    }
    
}

extension HomeViewController: UITableViewDataSource {
    //セクション中のセルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    //セルのLabelに記事のタイトルを表示(限定共有のものには[限定共有]と先頭につけるよう場合分け)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Storyboardで設定したセルのIdentifierを指定。
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomsCell", for: indexPath as IndexPath)
        tableView.rowHeight = 130
        
        //ラベルオブジェクトを作る
        let labelTitle = cell.viewWithTag(1) as! UILabel
        let labelcreateTime = cell.viewWithTag(2) as! UILabel
        let labelBody = cell.viewWithTag(3) as! UILabel
        //ラベルに表示する文字列を設定
        labelTitle.text = rooms[indexPath.row].title
        labelcreateTime.text = rooms[indexPath.row].updated_at
        labelBody.text = rooms[indexPath.row].body
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomsCell")!
//        let content = cell.defaultContentConfiguration()
//        let createTimeString = String(rooms[indexPath.row].updated_at)
        
//        titlerLabel.text = rooms[indexPath.row].title
//        bodyLabel.text = rooms[indexPath.row].body
//        createTimeLabel.text = createTimeString
//        cell.contentConfiguration = content
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
