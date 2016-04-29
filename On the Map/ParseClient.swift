//
//  ParseClient.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/28/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    let httpClient = HttpClient.sharedInstance()
    
    func fetchEntries(completionHandler: (fetchedStudents: [StudentLocation]!, error: NSError?) -> Void) {
        func sendError(error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandler(fetchedStudents: nil, error: NSError(domain: "login", code: 1, userInfo: userInfo))
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        httpClient.taskForRequest(request) { data, error in
            if let error = error {
                sendError("There was an error during fetchEntries: \(error)")
                return
            }

            var parsedResult: AnyObject!
            do {
                try parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data as JSON: \(data)")
                return
            }
            
            var students = [StudentLocation]()
            
            if let studentResults = parsedResult["results"] as? [[String:AnyObject]] {
                for studentResult in studentResults {
                    let uniqueKey = studentResult["uniqueKey"] as? String
                    if let
                        objectId = studentResult["objectId"] as? String,
                        firstName = studentResult["firstName"] as? String,
                        lastName = studentResult["lastName"] as? String,
                        mapString = studentResult["mapString"] as? String,
                        mediaURL = studentResult["mediaURL"] as? String,
                        latitude = studentResult["latitude"] as? Float,
                        longitude = studentResult["longitude"] as? Float
                    {
                        let studentLocation = StudentLocation(
                            objectId: objectId,
                            uniqueKey: uniqueKey,
                            firstName: firstName,
                            lastName: lastName,
                            mapString: mapString,
                            mediaURL: mediaURL,
                            latitude: latitude,
                            longitude: longitude)
                        students.append(studentLocation)
                    }
                }
            } else {
                sendError("Could not find key \"results\" in data: \(parsedResult)")
                return
            }
            
            print("fetched \(students.count) students")
            completionHandler(fetchedStudents: students, error: nil)
            
        }
        
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
}
