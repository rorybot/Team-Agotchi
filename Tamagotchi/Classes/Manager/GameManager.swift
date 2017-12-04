//
//  GameManager.swift
//  Tamagotchi
//
//  Created by MacBook Pro on 10/11/2017.
//  Copyright © 2017 Tammo Team. All rights reserved.
//

import Foundation

class GameManager {
    var egg = Egg(size: 0, age: 0, temp: 10, cracked: false)
    var lion = Lion(size: 10, age: 6, temp: 15, hungry: true, bursting: false, born: false)
    
    
    func newEgg(){
        egg = Egg(size: 0, age: 0, temp: 10, cracked: false)
    }
    
    var hungryDays = 0
    
    var age = 0
    var hour = 0
    var playDays = 0
    var happyDays = 0
}
