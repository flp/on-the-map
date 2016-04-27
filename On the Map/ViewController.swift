//
//  ViewController.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/26/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let username = "username@domain.com"
        let password = "********"
        UdacityClient.sharedInstance().login(username, password: password) { userDetails, error in
            guard let userDetails = userDetails else {
                print("error!")
                return
            }
            
            print(userDetails)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

