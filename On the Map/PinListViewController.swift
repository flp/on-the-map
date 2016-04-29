//
//  PinListViewController.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/27/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import UIKit

class PinListViewController: UITableViewController {
    
    var students: [StudentLocation] {
        get {
            let tabBarController = self.tabBarController as! TabBarViewController
            return tabBarController.students!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell")!
        let student = students[indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = students[indexPath.row]
        if !studentLocation.openStudentURL() {
            print("Failed to open url: \(studentLocation.mediaURL)")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
}
