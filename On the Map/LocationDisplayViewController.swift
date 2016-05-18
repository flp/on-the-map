//
//  LocationDisplayViewController.swift
//  On the Map
//
//  Created by Franklin Pearsall on 5/1/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import UIKit

class LocationDisplayViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView!
    var logoutButton: UIBarButtonItem!
    var newPinButton: UIBarButtonItem!
    var refreshButton: UIBarButtonItem!
    var mapTabButton: UITabBarItem!
    var listTabButton: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func newPin() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let userDetails = appDelegate.userDetails!
        setNetworkActivityUI(true)
        
        ParseClient.sharedInstance().queryForStudentLocation(userDetails.userId) { userDetails, error in
            dispatch_async(dispatch_get_main_queue()) {
                self.setNetworkActivityUI(false)
            }
            
            if let error = error {
                print("error querying for student location: \(error)")
                return
            }
            
            if let _ = userDetails {
                dispatch_async(dispatch_get_main_queue()) {
                    let message = "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?"
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                    
                    let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default) { _ in
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewPinViewController") as! NewPinViewController
                        controller.overrwrite = true
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                    
                    alert.addAction(overwriteAction)
                    alert.addAction(cancelAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewPinViewController") as! NewPinViewController
                    controller.overrwrite = false
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    func refreshPins() {
        print("refresh pins")
    }
    
    func logout() {
        print("logout")
    }
    
    private func setNetworkActivityUI(enabled: Bool) {
        if enabled {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        
        self.activityIndicator.hidden = !enabled
        self.logoutButton.enabled = !enabled
        self.newPinButton.enabled = !enabled
        self.refreshButton.enabled = !enabled
        self.mapTabButton.enabled = !enabled
        self.listTabButton.enabled = !enabled
    }
    
}
