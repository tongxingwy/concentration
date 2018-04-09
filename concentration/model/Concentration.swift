//
//  Concentration.swift
//  concentration
//
//  Created by tongxingwy on 2018/4/4.
//  Copyright © 2018 tongxingwy. All rights reserved.
//

import Foundation

class Concentration{
    var cards = [Card]()
    var lastSelectedIndex:Int?
    
    init(numberOfPairsOfCards:Int){
        for _ in 1...numberOfPairsOfCards{
            let card = Card()
            self.cards += [card,card]
        }
        //shuttle
        let count = self.cards.count
        for _ in self.cards.indices{
            self.cards.swapAt(self.random(upperCount: count), self.random(upperCount: count))
        }
    }
    
    func random(upperCount:Int) -> Int {
        return Int(arc4random_uniform(UInt32(upperCount)))
    }
    
    func chooseCard(at index: Int){
        if self.cards[index].isMatched{
            return
        }
        if self.lastSelectedIndex != nil && index != self.lastSelectedIndex{
            if(self.cards[index].identifier == self.cards[self.lastSelectedIndex!].identifier){
                self.cards[index].isMatched = true
                self.cards[self.lastSelectedIndex!].isMatched = true
            }
            self.cards[index].isFaceup = true
            self.lastSelectedIndex = nil
        }else{
            for idx in self.cards.indices{
                self.cards[idx].isFaceup = (index == idx)
            }
            self.lastSelectedIndex = index
        }
    }
}
