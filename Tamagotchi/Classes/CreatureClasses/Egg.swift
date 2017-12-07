//
//  Egg.swift
//  Tamagotchi
//
//  Created by James Hughes, Benjamin on 07/11/2017.
//  Copyright © 2017 Tammo Team. All rights reserved.
//

import Foundation

class Egg {
    
    var size: Int
    var age: Int
    var temp: Int
    var cracked: Bool {
        didSet{
            print("Cracked change")
        }
    }
    var wearingHat = false

    
    init(size: Int, age: Int, temp: Int, cracked: Bool? = false) {
        self.size = size;
        self.age = age;
        self.temp = temp;
        self.cracked = cracked!;
    }
    
    func incubate(innerFunction:@escaping()->Void){
        if cracked == false && wearingHat == true {
            if temp < 18 {
                return temp += 1
            } else {
                cracked = true
                wearingHat = false
                return innerFunction()
            }
        }
        
    }
}




