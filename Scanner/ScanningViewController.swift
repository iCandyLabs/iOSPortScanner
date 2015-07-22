//
//  ScanningViewController.swift
//  Scanner
//
//  Created by Maxence Ho on 21/07/2015.
//  Copyright (c) 2015 Maxence Ho. All rights reserved.
//

import UIKit

class ScanningViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Instance variables
    // --- Scan variables ---
    var localOpenPorts: [String] = []
    var wifiOpenPorts:  [String] = []
    // --- UI Elements ---
    @IBOutlet weak var cancelButton:  UIButton!
    @IBOutlet weak var topLabel:      UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var resultTable:   UITableView!
    var progressCounter:     Int = 0
    var maxOperation:        Int = 0
    // --- IP Variables ---
    let localHost = "127.0.0.1"
    var publicIP: String?
    // --- Brute force sockets ---
    var bsocket: [GCDAsyncSocket] = []
    var csocket: [GCDAsyncSocket] = []
    // --- Concurrency queues ---
    let queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    let queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
    let queue3 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
    
    // MARK: - View Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        // --- UI related operations ---
        self.view.bringSubviewToFront(self.cancelButton)
        self.view.bringSubviewToFront(self.topLabel)
        self.view.bringSubviewToFront(self.resultTable)
        cancelButton.layer.cornerRadius  =  5
        cancelButton.layer.borderWidth   =  3
        cancelButton.layer.borderColor   =  UIColor(red: 191/255, green: 76/255, blue: 86/255, alpha: 1).CGColor
        cancelButton.layer.shadowColor   =  UIColor.blackColor().CGColor
        cancelButton.layer.shadowOffset  =  CGSizeMake(0.65, 0.45)
        cancelButton.layer.shadowRadius  =  1
        cancelButton.layer.shadowOpacity =  0.55
        resultTable.allowsSelection      =  false;
        // --- Generate maxNbOperation
        if (publicIP != nil)
        {
            maxOperation = 65536 * 2
        }
        else
        {
            maxOperation = 65536
        }
        // --- Bind UI elmts for delegates ---
        self.resultTable.registerNib(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        // --- Launch listeners ---
        listenForResults()
        // --- Brute force connection test on all ports ---
        dispatch_async(queue3,{
            for j in 0...65535
            {
                
                if (!self.bsocket[j].connectToHost("127.0.0.1", onPort: UInt16(j), withTimeout:0.2, error: nil))
                {
                    println("Error")
                }
                else
                {
                    self.updateProgress()
                }
                afterDelay(0.2, {
                    self.bsocket[j].disconnect()
                })
            }
            
            // Scan wifi IP if existing
            if (self.publicIP != nil)
            {
                // Create the async sockets
                for i in 1...65536
                {
                    self.csocket.append(GCDAsyncSocket(delegate: self, delegateQueue: self.queue1))
                }
                
                // BruteForce wifi IP
                var IP = self.publicIP as String!
                for i in 1...65535
                {
                    if (!self.csocket[i].connectToHost("\(IP)", onPort: UInt16(i), withTimeout:0.2, error: nil))
                    {
                        println("Error")
                    }
                    else
                    {
                        self.updateProgress()
                    }
                    afterDelay(0.2, {
                        self.csocket[i].disconnect()
                    })
                }
            }
            
            // --- Update UI ---
            dispatch_sync(dispatch_get_main_queue(), {
                self.topLabel.text = "Done!"
                self.cancelButton.setTitle("Home", forState: .Normal)
                self.cancelButton.layer.borderColor   =  UIColor(red: 66/255, green: 166/255, blue: 75/255, alpha: 1).CGColor
                self.cancelButton.setTitleColor(UIColor(red: 66/255, green: 166/255, blue: 75/255, alpha: 1), forState: UIControlState.Normal)
                self.progressLabel.text = "100%"
            })
        })
        
        // --- Display notification if no public IP ---
        afterDelay(1, {
            self.displayHudView(self.publicIP == nil)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification Listeners
    func listenForResults() {
        let portHasBeenFound = "PortFound"
        NSNotificationCenter.defaultCenter().addObserverForName( portHasBeenFound, object: nil, queue: NSOperationQueue.mainQueue(),
        usingBlock: { notification in
            let message = notification.object as! [String]
            let host = message[0]
            let port = message[1]
            if (host == self.localHost)
            {
                if let index = find(self.localOpenPorts, port)
                {
                    NSLog("\(port) was already in locaOpenPorts array")
                }
                else
                {
                    self.localOpenPorts.append(port)
                    self.resultTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                }
            }
            else if (host == self.publicIP)
            {
                println("*** wifi ***")
                if let index = find(self.wifiOpenPorts, port)
                {
                    NSLog("\(port) was already in wifiOpenPorts array")
                }
                else
                {
                    self.wifiOpenPorts.append(port)
                    self.resultTable.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
                }
            }
            
        })
    }

    func updateProgress() {
        self.progressCounter = self.progressCounter + 1
        var progress: Int = Int(floor(Double(self.progressCounter)/Double(self.maxOperation) * 100))
        // UI update progress Label
        dispatch_sync(dispatch_get_main_queue(), {
            self.progressLabel.text = "\(progress)%"
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
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (publicIP != nil)
        {
            return 2
        }
        else
        {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //NSLog("** Creating Table Cell at section \(section)")
        if (section == 0)
        {
            return localOpenPorts.count
        }
        else if (section == 1 && (publicIP != nil))
        {
            return wifiOpenPorts.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0)
        {
            return "Localhost - 127.0.0.1   "
        }
        else if (section == 1 && (publicIP != nil))
        {
            let section2Header = publicIP as String!
            return "IP: \(section2Header)"
        }
        else
        {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: ResultCell = tableView.dequeueReusableCellWithIdentifier("ResultCell", forIndexPath: indexPath) as! ResultCell
        cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        if(indexPath.section == 0)
        {
            cell.iPValue.text = "127.0.0.1"
            cell.portNumber.text = localOpenPorts[indexPath.row]
        }
        else if((indexPath.section == 1) && (publicIP != nil))
        {
            cell.iPValue.text = publicIP as String!
            cell.portNumber.text = wifiOpenPorts[indexPath.row]
        }
        return cell
    }

    // MARK: - Segue's functions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Cancel"
        {
            let controller = segue.destinationViewController as! ViewController
            controller.bsocket = self.bsocket
        }
    }
    func socket(socket : GCDAsyncSocket, didReadData data:NSData, withTag tag:UInt16)
    {
        var response = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Received Response")
    }

    func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16)
    {
        println("Connected to \(host) on port \(p).")
        // --- Create Msg ---
        var test = publicIP as String!
        var message = [test, String(p)]
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

