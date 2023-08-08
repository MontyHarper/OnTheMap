//
//  ViewControllerExtension.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//
//  This extension adds functionality that needs to be accessible from multiple different view controllers.
//


import Foundation
import UIKit


extension UIViewController {
    
    
    // MARK: - logout function and completion handler
    
    // Logs the user out when they tap the logout button in navigation.
    @IBAction func logout(_ sender: UIBarButtonItem) {
        MapClient.logout(completion: logoutCompletion(success:))
    }
    
    func logoutCompletion(success: Bool) {
        if !success {
            self.showAlert(title: "Unable to logout.", message: "Please try again later.")
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Alert Function
    
    /*
     Shows an alert with the given title and message.
     Can optionally include a completion closure in the function call.
     The closure is used to dismiss the pin drop view after user acknowledges the "pin had been dropped" message.
     */
    
    func showAlert(title: String, message: String, completion:@escaping () -> Void = {}) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {_ in completion()}))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Non-Empty String Function for checking input
    
    /*
     Checks whether a string is nil, empty, or just full of spaces.
     Returns true if the string has content.
     */
    
    func nonemptyString(_ text:String?) -> Bool {
        
        if let text = text {
            
            guard text != "" else {
                return false // string is empty
            }
            
            for char in text {
                if char != " " { // string is not all spaces
                    return true
                }
            }
            return false // string is all spaces
            
        } else {
            return false // string is nil
        }
    }
}
