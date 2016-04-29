//
//  MapViewController.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/27/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    var students: [StudentLocation] {
        get {
            let tabBarController = self.tabBarController as! TabBarViewController
            return tabBarController.students!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.delegate = self
        
        self.map.addAnnotations(students)
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
