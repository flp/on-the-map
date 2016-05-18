//
//  PinListViewController.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/27/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import UIKit

class PinListViewController: LocationDisplayViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var activityIndicatorOutlet: UIActivityIndicatorView!
    @IBOutlet weak var logoutButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var newPinButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var refreshButtonOutlet: UIBarButtonItem!
    
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
    
    // BarButtons
    
    @IBAction func logout(sender: AnyObject) {
        super.logout()
    }
    
    @IBAction func newPin(sender: AnyObject) {
        super.newPin()
    }
    
    @IBAction func refresh(sender: AnyObject) {
        super.refreshPins()
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
