//
//  StudentLocation.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/28/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import Foundation
import MapKit

class StudentLocation: NSObject, MKAnnotation {
    
    var objectId: String
    var uniqueKey: String?
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Float
    var longitude: Float
    
    init(objectId: String, uniqueKey: String?, firstName: String, lastName: String, mapString: String,
         mediaURL: String, latitude: Float, longitude: Float) {
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: Double(self.latitude), longitude: Double(self.longitude))
        }
    }
    
}