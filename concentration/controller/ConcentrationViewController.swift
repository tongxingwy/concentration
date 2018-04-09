//
//  ViewController.swift
//  concentration
//
//  Created by tongxingwy on 2018/4/4.
//  Copyright © 2018 tongxingwy. All rights reserved.
//

import UIKit
import WatchConnectivity

class ConcentrationViewController: UIViewController,WCSessionDelegate {
    let session = WCSession.default
    let FLIP_COUNT_KEY = "flipCount"
    var game:Concentration! {
        didSet{
            self.updateCardViewFromModel()
        }
    }
    var flipCount = 0{
        didSet{
            self.flipCountLabel.text = "Flip count: \(self.flipCount)"
        }
    }
    var emojiChoice = ["🍎","🍌","🍊","🍍","🍇","🐔","🐶","🎾","🚕","🐥","🐷","🦖","🍑","🍓","🥝","🌶","🍐"]
    var emojis = [Int: String]()
    
    @IBOutlet var cardViews:[UIButton]!
    @IBOutlet weak var flipCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.game = Concentration(numberOfPairsOfCards: (self.cardViews.count + 1)/2)
        self.session.delegate = self
        self.session.activate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.flipCount > 0{
            self.sendMessageToWatch()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction
    func touchCardView(_ sender:UIButton){
        let idx = self.cardViews.index(of: sender)
        self.flipCount += 1
        self.game.chooseCard(at: idx!)
        self.updateCardViewFromModel()
        self.sendMessageToWatch()
    }
    
    func updateCardViewFromModel() {
        for idx in self.cardViews.indices{
            let card = self.game.cards[idx]
            let cardView = self.cardViews[idx]
            if card.isFaceup{
                cardView.setTitle(emoji(for: card), for: .normal)
                cardView.backgroundColor = UIColor.clear
            }else{
                cardView.setTitle("", for: .normal)
                cardView.backgroundColor = card.isMatched ? UIColor.green : UIColor.orange
            }
        }
    }
    
    func emoji(for card:Card) -> String {
        if self.emojis[card.identifier] == nil && self.emojiChoice.count > 0{
            let randomIdx = arc4random_uniform(UInt32(self.emojiChoice.count))
            self.emojis[card.identifier] = self.emojiChoice.remove(at: Int(randomIdx))
        }
        return self.emojis[card.identifier] ?? "☁️"
    }
    
    func sendMessageToWatch(){
        if self.session.isReachable {
            self.session.sendMessage([FLIP_COUNT_KEY:self.flipCount], replyHandler: nil, errorHandler: nil)
        }
    }
    
    //watch connectivity session delegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session complete state: \(activationState), error: \(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let flipCount = message[FLIP_COUNT_KEY] as? Int{
            DispatchQueue.main.async{
                self.flipCount = flipCount
            }
        }
    }


}

