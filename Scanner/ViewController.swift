//
//  ViewController.swift
//  Scanner
//
//  Created by Maxence Ho on 20/07/2015.
//  Copyright (c) 2015 Maxence Ho. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    // MARK: - Instance variables
    // --- UI Elements ---
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var background: UIImageView!
    // --- IP Variables ---
    let localHost = "127.0.0.1"
    var publicIP: String?
    // --- Brute force sockets ---
    var bsocket: [GCDAsyncSocket] = []
    // --- Concurrency queues ---
    let queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    let queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
    
    // MARK: - View Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        // --- UI related functions ---
        self.view.bringSubviewToFront(self.scanButton)
        self.view.sendSubviewToBack(self.background)
        scanButton.layer.cornerRadius  =  5
        scanButton.layer.borderWidth   =  3
        scanButton.layer.borderColor   =  UIColor(red: 191/255, green: 76/255, blue: 86/255, alpha: 1).CGColor
        scanButton.layer.shadowColor   =  UIColor.blackColor().CGColor
        scanButton.layer.shadowOffset  =  CGSizeMake(0.65, 0.45)
        scanButton.layer.shadowRadius  =  1
        scanButton.layer.shadowOpacity =  0.55
        // --- Get public IP if existing ---
        println("At init, array length \(bsocket.count)")
        dispatch_async(queue1, {
            // Request
            dispatch_sync(self.queue2, {
                self.publicIP = searchPublicIP()
            })
            // UI Changes
            dispatch_sync(dispatch_get_main_queue(), {
                println("Public key is \(self.publicIP)")
                self.displayHudView((self.publicIP == nil))
            })
        })
    }
    
    // MARK: - HUD related functions
    func displayHudView(isNecessary: Bool) {
        if(isNecessary == true)
        {
            let hudview  = HudView.hudInView(self.view, animated: true)
            NSLog("Display notification")
            hudview.text =  "No Wifi connection detected" + "\n" + "-> Scan only LocalHost"
            afterDelay(2.6) {
                hudview.hideAnimation()
            }
        }
        else
        {
            // Do nothing
        }
    }
    
    // MARK: - Segue's functions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Scanning"
        {
            let controller = segue.destinationViewController as! ScanningViewController
            controller.bsocket  = self.bsocket
            controller.publicIP = self.publicIP
        }
    }

}

