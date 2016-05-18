//
//  NewPinViewController.swift
//  On the Map
//
//  Created by Franklin Pearsall on 5/11/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class NewPinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var overrwrite: Bool!
    var location: String!
    var coordinate: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedString = NSMutableAttributedString(string:"Where are you\n")
        let boldText = "studying\n"
        let string2 = NSMutableAttributedString(string:"today?")
        let attrs = [NSFontAttributeName: UIFont.boldSystemFontOfSize(20)]
        let boldString = NSMutableAttributedString(string: boldText, attributes: attrs)
        attributedString.appendAttributedString(boldString)
        attributedString.appendAttributedString(string2)
        headerLabel.attributedText = attributedString
        
        locationTextField.delegate = self
        linkTextField.delegate = self
        
        bottomButton.layer.cornerRadius = 6
        bottomButton.clipsToBounds = true
        
        activityIndicator.hidden = true
        
        mapView.hidden = true
        
        linkTextField.hidden = true
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findLocation(sender: AnyObject) {
        location = locationTextField.text != nil ? locationTextField.text! : ""
        let geocoder = CLGeocoder()
        setNetworkActivityUI(true)
        geocoder.geocodeAddressString(location) { (placemarks: [CLPlacemark]?, error: NSError?) in
            
            func showError() {
                dispatch_async(dispatch_get_main_queue()) {
                    let message = "Could not find a map coordinate for your location"
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                    let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.setNetworkActivityUI(false)
            }
            
            if let error = error {
                print("Error during geocoding: \(error)")
                showError()
                return
            }
            
            if placemarks == nil {
                print("No placemark found for location: \(self.location)")
                showError()
                return
            }
            
            let placemark = placemarks![0]
            self.coordinate = placemark.location!.coordinate
            
            dispatch_async(dispatch_get_main_queue()) {
                self.topView.backgroundColor = self.view.tintColor
                self.headerLabel.hidden = true
                self.linkTextField.hidden = false
                self.cancelButton.tintColor = UIColor.whiteColor()
                self.bottomButton.setTitle("Submit", forState: .Normal)
                self.bottomButton.removeTarget(self, action: #selector(self.findLocation), forControlEvents: UIControlEvents.TouchUpInside)
                self.bottomButton.addTarget(self, action: #selector(self.submit), forControlEvents: UIControlEvents.TouchUpInside)
                
                self.mapView.hidden = false
                let pin = TemporaryPin(latitude: Float(self.coordinate.latitude), longitude: Float(self.coordinate.longitude))
                self.mapView.addAnnotation(pin)
                let region = MKCoordinateRegion(center: self.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
                self.mapView.setRegion(region, animated: true)
                self.bottomView.backgroundColor = self.bottomView.backgroundColor?.colorWithAlphaComponent(0.25)
            }
        }
    }
    
    func submit(sender: AnyObject) {
        if linkTextField.text == "Enter a Link to Share Here" {
            let message = "Please enter a link before submitting"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let userDetails = appDelegate.userDetails!
        
        let studentLocation = NewStudentLocation(
            uniqueKey: userDetails.userId,
            firstName: userDetails.firstName,
            lastName: userDetails.lastName,
            mapString: location,
            mediaURL: linkTextField.text!,
            latitude: Float(coordinate.latitude),
            longitude: Float(coordinate.longitude)
        )
        
        let method = (overrwrite == true) ? "PUT" : "POST"
        print("submitting new student location with \(method)")
        
        setNetworkActivityUI(true)
        ParseClient.sharedInstance().postOrPutStudentLocation(method, newStudent: studentLocation) { success, error in
            
            self.setNetworkActivityUI(false)
            if !success {
                dispatch_async(dispatch_get_main_queue()) {
                    let message = "Could not \((self.overrwrite == true) ? "update" : "create") location"
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                    let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                appDelegate.newLocationFlag = true
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text!.isEmpty {
            if textField.restorationIdentifier == "location" {
                textField.text = "Enter Your Location Here"
            } else {
                textField.text = "Enter a Link to Share Here"
            }
        }
    }
    
    func setNetworkActivityUI(enabled: Bool) {
        if enabled {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        activityIndicator.hidden = !enabled
        cancelButton.enabled = !enabled
        bottomButton.enabled = !enabled
    }
}
