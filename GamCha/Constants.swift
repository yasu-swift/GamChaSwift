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
  let baseUrl = "http://localhost/api"
  let loginUrl = "http://localhost/api/login"
  let registerUrl = "http://localhost/api/register"
  let service = "GamchaApp"
}
