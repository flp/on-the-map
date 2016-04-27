//
//  ViewController.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/26/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let username = "username@domain.com"
//        let password = "********"
//        UdacityClient.sharedInstance().login(username, password: password) { userDetails, error in
//            guard let userDetails = userDetails else {
//                print("error!")
//                return
//            }
//            
//            print(userDetails)
//        }
        
        let loginButton: FBSDKLoginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

