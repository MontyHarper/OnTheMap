//
//  ViewController.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func login() {
        
            
        // Set up a request
        var request = URLRequest(url: MapClient.Endpoints.openSession.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode the body of the request as a json object.
        // Encoding throws errors, so return with an error message if an error gets thrown.
        // This seems unlikely since even if username and password are empty, a json object can be made from that.
        do {
            request.httpBody = try JSONEncoder().encode(SessionRequest(username: userName.text ?? " ", password: password.text ?? " "))
        } catch {
            print("Error - failed to parse json request into http body.")
            showAlert(title: "Something Went Wrong", message: "Please double check your email and password. If this message appears again, I'm afraid all is lost." )
            return
        }
        
        // Set up a session and task
        let session = URLSession.shared
        let task = session.dataTask(with: request) {data, response, error in
            
            if let data = data {
                let range = 5..<data.count
                let newData = data.subdata(in: range) // *subset response data!* /
                
                // Here we have data, but it may not be what we think, if the login was unsuccessful
                let decoder = JSONDecoder()
                do {
                    MapClient.Auth.sessionID = try decoder.decode(SessionResponse.self, from: newData).session.id
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "PresentTabBar", sender: nil)
                    }
                } catch {
                    // The data doesn't fit our response pattern
                    print("Error - Data does not fit expected response.")
                    print(String(data: data, encoding: .utf8))
                   
                        self.showAlert(title: "Incorrect email or password.", message: "Please check for typos and try again.")
                    
                }
            } else {
                // The response data was nil.
                print("Error - did not receive data in response.")
                
                    self.showAlert(title: "No Response", message: "The server is not responding as expected to your login attempt. Please try again later.")
                
            }
        }
        
        task.resume()
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
   
    
}

