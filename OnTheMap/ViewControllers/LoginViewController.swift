//
//  ViewController.swift
//  OnTheMap
//
//  Created by Monty Harper on 7/30/23.
//
//  Initial VC, allows user to log into the app.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        password.delegate = self
        loginButtonToggle() // Disables login button until both text fields are present.
    }
    
    
    
    // MARK: - IBActions
    
    // When user presses the login button, attempt to log them in.
    @IBAction func login() {
        
        // We can assume non-nil text values since the login button will be disabled otherwise.
        MapClient.login(username: userName.text!, password: password.text!, completion: loginCompletion(success:error:))
    }
        
       
    
    // MARK: - Completion Handlers
    
    // Handle login response
    func loginCompletion(success: Bool, error: Error?) {
        
        if success {
            self.performSegue(withIdentifier: "PresentTabBar", sender: nil)
            
        } else {
            showAlert(title: "Login Error", message: "Please check your spelling and try again.")
            
            if let error = error {
                print("\(error)")
                }
            
            // Reset login form.
            userName.text = ""
            password.text = ""
            loginButtonToggle()
        }
    }
    
    
    
    // MARK: - Private Methods
    
    func loginButtonToggle() {
        // Enables login button only when both username and password are present.
        
        loginButton.isEnabled = nonemptyString(userName.text) && nonemptyString(password.text)
    }
    
    

    // MARK: - Delegate Functions
    
    // When user hits return, this dismisses the keyboard, toggles the login button.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        loginButtonToggle()
        return true
    }
    

    
    // Toggles login button as soon as both fields are non-empty.
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        loginButtonToggle()
    }
    
   
    
}

