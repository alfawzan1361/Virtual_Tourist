//
//  UdacityAPI.swift
//  Virtual_Tourist
//
//  Created by AF on 12/3/19.
//  Copyright © 2019 amaf. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class UdacityAPI {
    
    class func sharedInstance() -> UdacityAPI {
        struct Singleton {
            static var sharedInstance = UdacityAPI()
        }
        return Singleton.sharedInstance
    }
    
    static func login (_ email : String!, _ password : String!, completion: @escaping (Bool, String, Error?)->())  {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email!)\", \"password\": \"\(password!)\"}}".data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion (false, "", error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion (false, "", error)
                return
            }
            
            if statusCode >= 200 && statusCode < 300 {
                let range = 5..<data!.count
                let newData = data?.subdata(in: range)
                print (String(data: newData!, encoding: .utf8)!)
                
                let loginJsonObject = try! JSONSerialization.jsonObject(with: newData!, options: [])
                let loginDictionary = loginJsonObject as? [String : Any]
                let accountDictionary = loginDictionary? ["account"] as? [String : Any]
                let key = accountDictionary? ["key"] as? String ?? " "
                
                completion (true, key, nil)
            } else {
                completion (false, "", nil)
            }
        }
        task.resume()
    }
}
