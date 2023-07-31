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
    
}
