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
        
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
