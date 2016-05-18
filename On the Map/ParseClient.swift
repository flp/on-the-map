//
//  ParseClient.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/28/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    
    let httpClient = HttpClient.sharedInstance()
    
    func fetchEntries(completionHandler: (fetchedStudents: [StudentLocation]!, error: NSError?) -> Void) {
        func sendError(error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandler(fetchedStudents: nil, error: NSError(domain: "fetchEntries", code: 1, userInfo: userInfo))
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100&order=-updatedAt")!)
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
    
    func queryForStudentLocation(uniqueKey: String, completionHandler: (userDetails: UserDetails?, error: NSError?) -> Void) {
        func sendError(error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandler(userDetails: nil, error: NSError(domain: "queryForStudentLocation", code: 1, userInfo: userInfo))
        }
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        httpClient.taskForRequest(request) { data, error in
            if let error = error {
                sendError("There was an error during queryForStudentLocation: \(error)")
                return
            }
            
            var parsedResult: AnyObject!
            do {
                try parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data as JSON: \(data)")
                return
            }
            
            if let studentResults = parsedResult["results"] as? [[String:AnyObject]] {
                if studentResults.isEmpty {
                    print("No user exists for \(uniqueKey)")
                    completionHandler(userDetails: nil, error: nil)
                    // TODO: remove hack
//                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                    completionHandler(userDetails: appDelegate.userDetails!, error: nil)
                } else {
                    print("User already exists for \(uniqueKey)")
                    
                    if let objectId = studentResults[0]["objectId"] as? String {
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.userDetails!.parseOjbectId = objectId
                        completionHandler(userDetails: appDelegate.userDetails!, error: nil)
                    } else {
                        sendError("Could not find key \"objectId\" in data \(parsedResult)")
                        return
                    }
                }
            } else {
                sendError("Could not find key \"results\" in data: \(parsedResult)")
                return
            }
            
        }
    }
    
    func postOrPutStudentLocation(method: String, newStudent: NewStudentLocation, completionHandler: (success: Bool, error: NSError?) -> Void) {
        func sendError(error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandler(success: false, error: NSError(domain: "postOrPutStudentLocation", code: 1, userInfo: userInfo))
        }
        
        var url: NSURL!
        if method == "PUT" {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            url = NSURL(string: "https://api.parse.com/1/classes/StudentLocation/\(appDelegate.userDetails!.parseOjbectId!)")
        } else {
            url = NSURL(string: "https://api.parse.com/1/classes/StudentLocation")
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(newStudent.uniqueKey)\", \"firstName\": \"\(newStudent.firstName)\", \"lastName\": \"\(newStudent.lastName)\",\"mapString\": \"\(newStudent.mapString)\", \"mediaURL\": \"\(newStudent.mediaURL)\",\"latitude\": \(newStudent.latitude), \"longitude\": \(newStudent.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        httpClient.taskForRequest(request) { data, error in
            if let error = error {
                sendError("There was an error during postOrPutStudentLocation: \(error)")
                return
            }
            
            var parsedResult: AnyObject!
            do {
                try parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data as JSON: \(data)")
                return
            }
            
            if method == "PUT" {
                if let _ = parsedResult["updatedAt"] as? String {
                    completionHandler(success: true, error: nil)
                } else {
                    sendError("There was an error PUTing student locßation: \(parsedResult)")
                    return
                }
            } else {
                if let _ = parsedResult["createdAt"] as? String {
                    completionHandler(success: true, error: nil)
                } else {
                    sendError("There was an error POSTing student location: \(parsedResult)")
                    return
                }
            }
        }
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
}
