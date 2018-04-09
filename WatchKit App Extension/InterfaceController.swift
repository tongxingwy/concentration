//
//  InterfaceController.swift
//  WatchKit App Extension
//
//  Created by tongxingwy on 2018/4/5.
//  Copyright © 2018 tongxingwy. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController,WCSessionDelegate,WKCrownDelegate {
    let session = WCSession.default
    let FLIP_COUNT_KEY = "flipCount"
    var crownIsIdle = true
    
    var flipCount = 0 {
        didSet{
            self.flipCountLabel.setText(String(self.flipCount))
        }
    }
    @IBOutlet var flipCountLabel: WKInterfaceLabel!
    
    //MARK: app life cycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        self.session.delegate = self
        self.session.activate()
        self.crownSequencer.delegate = self
        self.crownSequencer.focus()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if self.flipCount > 0{
            self.sendMessageToIphone()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        self.crownSequencer.resignFocus()
    }
    
    //MARK: button event handler
    @IBAction func fetchAction() {
        self.presentAlert(withTitle: "Concentration", message: "🍌🍎🍐🍍", preferredStyle: WKAlertControllerStyle.alert, actions: [WKAlertAction(title: "ok", style: WKAlertActionStyle.default, handler: {})])
    }
    
    @IBAction func minusAction() {
        self.changeFlipCount(byDelta: -1)
        self.crownSequencer.focus()
    }
    
    @IBAction func plusAction() {
        self.changeFlipCount(byDelta: 1)
        self.crownSequencer.focus()
    }
    
    @IBAction func pingAction() {
        let task = URLSession.shared.dataTask(with: URL(string:"https://wx.iotstar.club/health")!) { (data, response, error) in
            DispatchQueue.main.async{
                if let error = error{
                    self.presentAlert(withTitle: "Ping",
                                      message: "code:\(error)",
                                      preferredStyle: WKAlertControllerStyle.alert,
                                      actions: [WKAlertAction(title: "ok", style: WKAlertActionStyle.default, handler: {})])
                }else{
                    self.presentAlert(withTitle: "Ping",
                                      message: String(data:data! ,encoding:String.Encoding.utf8),
                                      preferredStyle: WKAlertControllerStyle.alert,
                                      actions: [WKAlertAction(title: "ok", style: WKAlertActionStyle.default, handler: {})])
                }
            }
        }
        task.resume()
    }
    
    //MARK: hanlde message and update UI
    func sendMessageToIphone(){
        if self.session.isReachable {
            self.session.sendMessage([FLIP_COUNT_KEY:self.flipCount], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func changeFlipCount(byDelta delta:Int) {
        if delta <= 0 && self.flipCount <= 0 {
            return
        }
        self.flipCount += delta
        self.sendMessageToIphone()
    }
    
    //MARK: WatchConnectivity delegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session complete state: \(activationState), error: \(String(describing: error))")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let flipCount = message[FLIP_COUNT_KEY] as? Int{
            DispatchQueue.main.async{
                self.flipCount = flipCount
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
    }
    //MARK: crown delegate
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if !self.crownIsIdle {
            return
        }
        if rotationalDelta >= 0.01 {
            self.crownIsIdle = false
            self.changeFlipCount(byDelta: 1)
        }else if rotationalDelta <= -0.01{
            self.crownIsIdle = false
            self.changeFlipCount(byDelta: -1)
        }
    }
    
    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        self.crownIsIdle = true
    }
    
}
