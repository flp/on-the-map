//
//  PinListViewController.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/27/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import UIKit

class PinListViewController: LocationDisplayViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicatorOutlet: UIActivityIndicatorView!
    @IBOutlet weak var logoutButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var newPinButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var refreshButtonOutlet: UIBarButtonItem!
    
    var newDataFlag = false
    
    var students: [StudentLocation] {
        get {
            let tabBarController = self.tabBarController as! TabBarViewController
            return tabBarController.students!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator = activityIndicatorOutlet
        self.logoutButton = logoutButtonOutlet
        self.newPinButton = newPinButtonOutlet
        self.refreshButton = refreshButtonOutlet
        self.mapTabButton = tabBarController?.tabBar.items![0]
        self.listTabButton = tabBarController?.tabBar.items![1]
        
        self.activityIndicator.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.newLocationFlag {
            super.refresh {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    
                    let nav = self.tabBarController!.childViewControllers[0] as! UINavigationController
                    let mapController = nav.topViewController as! MapViewController
                    mapController.newDataFlag = true
                    appDelegate.newLocationFlag = false
                }
            }
        } else if newDataFlag {
            self.tableView.reloadData()
            newDataFlag = false
        }
    }
    
    // BarButtons
    
    @IBAction func logout(sender: AnyObject) {
        super.logout()
    }
    
    @IBAction func newPin(sender: AnyObject) {
        super.newPin()
    }
    
    @IBAction func refreshPins(sender: AnyObject) {
        super.refresh {
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                
                let nav = self.tabBarController!.childViewControllers[0] as! UINavigationController
                let mapController = nav.topViewController as! MapViewController
                mapController.newDataFlag = true
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell")!
        let student = students[indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = students[indexPath.row]
        if !studentLocation.openStudentURL() {
            print("Failed to open url: \(studentLocation.mediaURL)")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
}
