//
//  Card.swift
//  concentration
//
//  Created by tongxingwy on 2018/4/4.
//  Copyright © 2018 tongxingwy. All rights reserved.
//

import Foundation

struct Card{
    var isMatched = false
    var isFaceup = false
    var identifier:Int
    
    static var identifierFactory = 0
    
    static func getUniqIdentifier() -> Int{
        identifierFactory = identifierFactory + 1
        return identifierFactory
    }
    
    init() {
        self.identifier = Card.getUniqIdentifier()
    }
}
