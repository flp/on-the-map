//
//  LoginViewController.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/26/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    var fbLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.indicator.hidden = true
        
        fbLoginButton = FBSDKLoginButton()
        fbLoginButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - 30)
        fbLoginButton.delegate = self
        self.view.addSubview(fbLoginButton)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self

        if let accessToken = FBSDKAccessToken.currentAccessToken() {
            self.setNetworkActivityUI(true)
            self.loginWithFacebookToken(accessToken.tokenString)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        let username = emailTextField.text!
        let password = passwordTextField.text!
        
        if username.isEmpty {
            self.presentLoginError("Username cannot be blank")
            return
        }
        
        if password.isEmpty {
            self.presentLoginError("Password cannot be blank")
            return
        }
        
        self.setNetworkActivityUI(true)
        UdacityClient.sharedInstance().login(username, password: password) { userDetails, error in
            
            guard let userDetails = userDetails else {
                print("error: \(error)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.setNetworkActivityUI(false)
                    self.presentLoginError("Error logging into Udacity")
                }
                return
            }
            
            self.completeLogin(userDetails)
        }

    }
    
    private func presentLoginError(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func completeLogin(userDetails: UserDetails) {
        print(userDetails)
        
        ParseClient.sharedInstance().fetchEntries { students, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.setNetworkActivityUI(false)
            }
            
            if let error = error {
                print("error: \(error)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentLoginError("Could not get student locations")
                    if FBSDKAccessToken.currentAccessToken() != nil {
                        FBSDKLoginManager.init().logOut()
                    }
                }
                return
            }
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.userDetails = userDetails
            
            dispatch_async(dispatch_get_main_queue()) {
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarViewController") as! TabBarViewController
                controller.students = students
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
        
        
    }
    
    private func setNetworkActivityUI(enabled: Bool) {
        if enabled {
            self.indicator.startAnimating()
            self.loginButton.alpha = 0.5
        } else {
            self.indicator.stopAnimating()
            self.loginButton.alpha = 1.0
        }
        
        self.indicator.hidden = !enabled
        self.loginButton.enabled = !enabled
        self.fbLoginButton.enabled = !enabled
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: FBSDKLoginButtonDelegate
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        self.setNetworkActivityUI(true)
        return true
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil || FBSDKAccessToken.currentAccessToken() == nil {
            self.setNetworkActivityUI(false)
            self.presentLoginError("Error logging into Facebook")
            return
        }
        
        self.loginWithFacebookToken(FBSDKAccessToken.currentAccessToken().tokenString)
    }
    
    private func loginWithFacebookToken(accessToken: String) {
        UdacityClient.sharedInstance().loginWithFacebook(accessToken) { userDetails, error in
            
            guard let userDetails = userDetails else {
                print("error: \(error)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.setNetworkActivityUI(false)
                    self.presentLoginError("Error getting user details")
                    FBSDKLoginManager.init().logOut()
                }
                return
            }
            
            self.completeLogin(userDetails)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        return
    }


}

