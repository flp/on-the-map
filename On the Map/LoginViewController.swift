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

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let fbLoginButton: FBSDKLoginButton = FBSDKLoginButton()
        fbLoginButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - 30)
        fbLoginButton.delegate = self
        self.view.addSubview(fbLoginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        let username = emailTextField.text!
        let password = passwordTextField.text!
        UdacityClient.sharedInstance().login(username, password: password) { userDetails, error in
            guard let userDetails = userDetails else {
                print("error!")
                return
            }
            
            print(userDetails)
        }

    }
    
    // MARK: FBSDKLoginButtonDelegate
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("logged into facebook, got token: \(FBSDKAccessToken.currentAccessToken().tokenString)")
        
        UdacityClient.sharedInstance().loginWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString) { userDetails, error in
            guard let userDetails = userDetails else {
                print("error!")
                return
            }
            
            print(userDetails)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        return
    }


}

