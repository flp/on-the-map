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
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.indicator.hidden = true
        
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
        self.setNetworkActivityUI(true)
        
        let username = emailTextField.text!
        let password = passwordTextField.text!
        UdacityClient.sharedInstance().login(username, password: password) { userDetails, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.setNetworkActivityUI(false)
            }
            
            guard let userDetails = userDetails else {
                print("error: \(error)")
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.completeLogin(userDetails)
            }
        }

    }
    
    private func completeLogin(userDetails: UserDetails) {
        print(userDetails)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.userDetails = userDetails
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarViewController") as! TabBarViewController
        self.presentViewController(controller, animated: true) {
            // TODO: should we dismiss, or stick around for logout event?
        }
    }
    
    private func setNetworkActivityUI(enabled: Bool) {
        if enabled {
            self.indicator.startAnimating()
        } else {
            self.indicator.stopAnimating()
        }
        
        self.indicator.hidden = !enabled
    }
    
    // MARK: FBSDKLoginButtonDelegate
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        self.setNetworkActivityUI(true)
        return true
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("logged into facebook, got token: \(FBSDKAccessToken.currentAccessToken().tokenString)")
        
        UdacityClient.sharedInstance().loginWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString) { userDetails, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.setNetworkActivityUI(false)
            }
            
            guard let userDetails = userDetails else {
                print("error: \(error)")
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.completeLogin(userDetails)
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        return
    }


}

