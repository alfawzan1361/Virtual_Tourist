//
//  Extensions.swift
//  Virtual_Tourist
//
//  Created by AF on 11/27/19.
//  Copyright © 2019 amaf. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertMessage(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(alertAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
