//
//  UdacityAPIView.swift
//  Virtual_Tourist
//
//  Created by AF on 12/3/19.
//  Copyright © 2019 amaf. All rights reserved.
//

import Foundation
import UIKit

class UdacityAPIView: UIViewController {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var logingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func login(_ sender: Any) {
            let email = usernameText.text
            let password = passwordText.text
            
            if (email!.isEmpty) || (password!.isEmpty) {
                let alert = UIAlertController (title: "Error", message: "Please enter Email and Password", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: .default, handler: { _ in
                    return
                }))
                self.present (alert, animated: true, completion: nil)
                
            } else {
                UdacityAPI.login(email, password){(success, key, error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            let alert = UIAlertController(title: "Erorr", message: "Failed Request", preferredStyle: .alert )
                            alert.addAction(UIAlertAction (title: "OK", style: .default, handler: { _ in
                                return
                            }))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        if !success {
                            let alert = UIAlertController(title: "Erorr", message: "Password or Email incorrect", preferredStyle: .alert )
                            alert.addAction(UIAlertAction (title: "OK", style: .default, handler: { _ in
                                return
                            }))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            print("Success Request")
                            if let mapAndTableController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") {
                                self.present(mapAndTableController, animated: true, completion: nil)}
                        }
                    }
                }
            }
        }
    }


