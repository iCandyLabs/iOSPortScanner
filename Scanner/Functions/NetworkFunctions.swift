//
//  NetworkFunctions.swift
//  Scanner
//
//  Created by Maxence Ho on 20/07/2015.
//  Copyright (c) 2015 Maxence Ho. All rights reserved.
//

import UIKit

// Query RESTFull API for ip; returns value of connection ip
func searchPublicIP() -> String? {
    var e: NSError?
    let urlPath: String = "https://api.ipify.org?format=json"
    var url: NSURL = NSURL(string: urlPath)!
    var request1: NSURLRequest  = NSURLRequest(URL: url)
    let queue: NSOperationQueue = NSOperationQueue()
    var publicIP: String?
    
    // Request
    var response: NSURLResponse?
    var error: NSError?
    // Synchronous request (not in main_queue so wont block UI thread)
    let urlData = NSURLConnection.sendSynchronousRequest(request1, returningResponse: &response, error: &error)
    if let httpResponse = response as? NSHTTPURLResponse {
        if (httpResponse.statusCode == 200)
        {
            publicIP = doThingsWithData(urlData!)
        }
        else
        {
            // Error contacting server
        }
    }
    return publicIP
}

func doThingsWithData(data: NSData) -> String? {
    var errorValue: NSError?
    if let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &errorValue) as? NSDictionary {
        let iPResponse = IPResponse(dictionary: dictionary as NSDictionary)
        return iPResponse.ip
    } else {
        // Error Network message
        return nil
    }
}

