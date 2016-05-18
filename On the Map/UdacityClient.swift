//
//  UdacityClient.swift
//  On the Map
//
//  Created by Franklin Pearsall on 4/26/16.
//  Copyright © 2016 Franklin Pearsall. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    let httpClient = HttpClient.sharedInstance()
    
    func login(username: String, password: String, completionHandler: (userDetails: UserDetails!, error: NSError?) -> Void) {
        let request = usernamePasswordLoginRequest(username, password: password)
        loginWithRequest(request, completionHandler: completionHandler)
    }
    
    func loginWithFacebook(accessToken: String, completionHandler: (userDetails: UserDetails!, error: NSError?) -> Void) {
        let request = facebookTokenLoginRequest(accessToken)
        loginWithRequest(request, completionHandler: completionHandler)
    }
    
    private func loginWithRequest(request: NSMutableURLRequest, completionHandler: (userDetails: UserDetails!, error: NSError?) -> Void) {
        
        func sendError(error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandler(userDetails: nil, error: NSError(domain: "login", code: 1, userInfo: userInfo))
        }
        
        httpClient.taskForRequest(request) { result, error in
            if let error = error {
                sendError("There was an error during login: \(error)")
                return
            }
            
            guard let parsedResult: AnyObject = self.parseUdacityResponse(result) else {
                sendError("Could not parse the data as JSON: '\(result)'")
                return
            }
            
            if let account = parsedResult["account"] as? [String:AnyObject], let userId = account["key"] as? String {
                self.getUserDetails(userId, completionHandler: completionHandler)
            } else {
                sendError("Cannot find key in \(parsedResult)")
                return
            }
        }
    }
    
    private func usernamePasswordLoginRequest(username: String, password: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        return request
    }
    
    private func facebookTokenLoginRequest(accessToken: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken);\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        return request
    }
    
    private func getUserDetails(userId: String, completionHandler: (userDetails: UserDetails!, error: NSError?) -> Void) {
        
        func sendError(error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandler(userDetails: nil, error: NSError(domain: "login", code: 1, userInfo: userInfo))
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userId)")!)
        
        httpClient.taskForRequest(request) { result, error in
            if let error = error {
                sendError("There was an error getting user details: \(error)")
                return
            }
            
            guard let parsedResult: AnyObject = self.parseUdacityResponse(result) else {
                sendError("Could not parse the data as JSON: '\(result)'")
                return
            }
            
            if let user = parsedResult["user"] as? [String:AnyObject], let firstName = user["first_name"] as? String, lastName = user["last_name"] as? String {
                
                completionHandler(userDetails: UserDetails(firstName: firstName, lastName: lastName, userId: userId, parseOjbectId: nil), error: nil)
            } else {
                sendError("Cannot find first name and last name in \(parsedResult)")
            }
        }
    }
    
    private func parseUdacityResponse(response: AnyObject!) -> AnyObject! {
        let newData = response.subdataWithRange(NSMakeRange(5, response.length - 5)) // subset response data!
        
        do {
            return try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            return nil
        }
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}

struct UserDetails {
    let firstName: String
    let lastName: String
    let userId: String
    var parseOjbectId: String?
}