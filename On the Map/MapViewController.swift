//
//  MapViewController.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/27/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import MapKit
import UIKit

class MapViewController: LocationDisplayViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var activityIndicatorOutlet: UIActivityIndicatorView!
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
        
        self.map.delegate = self
        
        self.map.addAnnotations(students)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.newLocationFlag {
            super.refresh {
                dispatch_async(dispatch_get_main_queue()) {
                    self.map.removeAnnotations(self.map.annotations)
                    self.map.addAnnotations(self.students)
                    
                    let nav = self.tabBarController!.childViewControllers[1] as! UINavigationController
                    let pinListController = nav.topViewController as! PinListViewController
                    pinListController.newDataFlag = true
                    appDelegate.newLocationFlag = false
                }
            }
        } else if newDataFlag {
            self.map.removeAnnotations(self.map.annotations)
            self.map.addAnnotations(self.students)
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
                self.map.removeAnnotations(self.map.annotations)
                self.map.addAnnotations(self.students)
                
                let nav = self.tabBarController!.childViewControllers[1] as! UINavigationController
                let pinListController = nav.topViewController as! PinListViewController
                pinListController.newDataFlag = true
            }
        }
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let studentLocation = annotation as! StudentLocation
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = studentLocation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: studentLocation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        }
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let studentLocation = view.annotation as! StudentLocation
        if !studentLocation.openStudentURL() {
            print("Failed to open url: \(studentLocation.mediaURL)")
        }
    }
    
}
