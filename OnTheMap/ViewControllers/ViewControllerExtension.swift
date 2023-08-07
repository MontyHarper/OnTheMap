//
//  ViewControllerExtension.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//

import Foundation
import UIKit

extension UIViewController {
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        var request = URLRequest(url: MapClient.Endpoints.logout.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                self.showAlert(title: "Unable to logout.", message: "Please try again later.")
                return
            }
            // verify logout
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
        }
        task.resume()
        
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    
    }
    
    func showAlert(title: String, message: String, completion:@escaping () -> Void = {}) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {_ in completion()}))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
