//
//  IPResponse.swift
//  Port Scanner
//
//  Created by Maxence Ho on 20/07/2015.
//  Copyright (c) 2015 Maxence Ho. All rights reserved.
//

import UIKit

class IPResponse: NSObject {
    
    var dict: NSDictionary
    
    init(dictionary: NSDictionary) {
        dict = dictionary
    }
    
    var ip: String? {
        get {
            return dict["ip"] as? String
        }
    }
    
}
