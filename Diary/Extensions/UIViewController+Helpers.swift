//
//  UIViewController+Helpers.swift
//  Diary
//
//  Created by Erik Carlson on 12/26/18.
//  Copyright © 2018 Round and Rhombus. All rights reserved.
//

import UIKit

extension UIViewController {
    /**
     Convenient way to show a standard alert.
     
     - Parameter title: The title of the alert.
     - Parameter message: The detailed message of the alert.
    */
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
