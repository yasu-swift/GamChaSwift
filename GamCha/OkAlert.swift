//
//  OkAlert.swift
//  GamCha
//
//  Created by 高橋康之 on 2021/11/24.
//

import UIKit

class OkAlert: UIAlertController {
    func showOkAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        viewController.present(alert, animated: true)
    }
}
