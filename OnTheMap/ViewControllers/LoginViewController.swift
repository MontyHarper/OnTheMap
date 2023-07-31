//
//  ViewController.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBAction func login() {
        performSegue(withIdentifier: "PresentTabBar", sender: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    
    
}

