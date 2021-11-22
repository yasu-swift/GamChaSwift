//
//  Constants.swift
//  GamCha
//
//  Created by 高橋康之 on 2021/11/21.
//

import Foundation

struct Constants {
    static let shared = Constants()
    private init() {}
    let service = "qiita_api_oauth"
    let clientID = "b7702fc811dd6df94a45095550f2f172ed8935d7" //自分のClient IDを入れて下さい
    let clientSecret = "4b50d9779e120ab9e319d92a18cb01796bbaa5be" //自分のClient Secretを入れて下さい

    let baseUrl = "https://qiita.com/api/v2" //QiitaAPIへのリクエストに使用します。

    //QiitaAPIのアクセストークンと交換するcode発行に利用します。
    let oAuthUrl = "https://qiita.com/api/v2/oauth/authorize"

    let scopes = "read_qiita+write_qiita" //このアプリにほしいQiitaAPIの権限を書いています。
    let callbackUrlScheme = "qiita-api-oauth"
}
