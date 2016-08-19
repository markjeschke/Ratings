//
//  ApiManager.swift
//  Ratings
//
//  Created by Mark Jeschke on 8/17/16.
//  Copyright © 2016 Mark Jeschke. All rights reserved.
//

import UIKit
import Foundation

class ApiManager: NSObject {
    
    // Create an array to house the JSON results.
    var jsonResults = [[String: AnyObject]]()
    
    // Set the URL for the API request
    var baseUrl: String?
    
    // Detect whether a network connection has been checked.
    var networkChecked: Bool = false
    
    // Make this class a singleton.
    static let sharedInstance = ApiManager()
    
    func getApiRequest(trackId:String) {
        
        self.baseUrl = "https://itunes.apple.com/lookup?id=\(trackId)"
        
        let apiUrl: NSURL = NSURL(string:self.baseUrl!)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: apiUrl)
        let session = NSURLSession.sharedSession()
        
        // Place the data task request off of the main thread.
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        dispatch_async(queue) {
            
            let task = session.dataTaskWithRequest(urlRequest) {
                (data, response, error) -> Void in
                
                if response != nil {
                    
                    self.networkChecked = false
                    
                    // Show activity indicator
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    
                    let httpResponse = response as! NSHTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    if (statusCode == 200) {
                        
                        // Hide activity indicator.
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                            
                            self.jsonResults = (json["results"] as? [[String: AnyObject]])!
                            
                            // Update UI on the main thread.
                            dispatch_async(dispatch_get_main_queue(), {
                                NSNotificationCenter.defaultCenter().postNotificationName("refreshContent", object: self)
                            })
                        } catch {
                            // Alert the user with an error if JSON can't be received.
                            NSNotificationCenter.defaultCenter().postNotificationName("alertController", object: self, userInfo:["error":"Error with JSON: \(error)"])
                        }
                    }
                } else {
                    if !self.networkChecked {
                        // Alert the user if a network connection isn't found.
                        NSNotificationCenter.defaultCenter().postNotificationName("alertController", object: self, userInfo:["error":"Internet connection appears to be offline. Please establish a data or Wi-Fi connection."])
                        self.networkChecked = true
                    }
                }
            }
            task.resume()
        }
    }
}