//
//  AppDelegate.swift
//  Scanner
//
//  Created by Maxence Ho on 20/07/2015.
//  Copyright (c) 2015 Maxence Ho. All rights reserved.
//

import UIKit

let portHasBeenFound = "PortFound"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var publicIP: String?
    var window:   UIWindow?
    let queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    let queue3 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
    // --- Brute force sockets ---
    var bsocket: [GCDAsyncSocket] = []
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let rootController = self.window!.rootViewController as! ViewController
        // --- Initialize sockets for brute force ---
        for i in 1...65536
        {
            self.bsocket.append(GCDAsyncSocket(delegate: self, delegateQueue: self.queue1))
        }
        println("*** Brute arrray init done")
        rootController.bsocket = self.bsocket
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {}
    
    func applicationDidEnterBackground(application: UIApplication) {}
    
    func applicationWillEnterForeground(application: UIApplication) {}
    
    func applicationDidBecomeActive(application: UIApplication) {}
    
    func applicationWillTerminate(application: UIApplication) {}
    
    // MARK: - GCDAsyncSocket delegates
    func socket(socket : GCDAsyncSocket, didReadData data:NSData, withTag tag:UInt16)
    {
        var response = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("Received Response")
    }
    
    func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16)
    {
        println("Connected to \(host) on port \(p).")
        // --- Create Msg ---
        var message = [host, String(p)]
        // --- Send notification ---
        NSNotificationCenter.defaultCenter().postNotificationName(portHasBeenFound, object: message)
        socket.disconnect()
    }
    
    func socket(socket: GCDAsyncSocket, shouldTimeoutReadWithTag tag:UInt16){
        println("timeout")
    }
    
    func socket(socket: GCDAsyncSocket, shouldTimeoutWriteWithTag tag:UInt16){
        println("timeout")
    }
    
}

