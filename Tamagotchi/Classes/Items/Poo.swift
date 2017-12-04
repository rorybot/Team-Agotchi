//
//  Poo.swift
//  Tamagotchi
//
//  Created by James Hughes on 13/11/2017.
//  Copyright © 2017 Tammo Team. All rights reserved.
//

import Foundation
import SpriteKit

class VisualPoo: SKSpriteNode {
    
    var alreadyFlower = false
    var age = 0
    
    
    func initialize(name: String, position: CGPoint, pooCounter: Float){
        self.name = name
        self.size = CGSize(width:100.0, height: 100.0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = position
        self.zPosition = CGFloat(4 + pooCounter);
        self.texture = SKTexture(imageNamed: "poop.png")
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size);
        self.physicsBody?.affectedByGravity = true;
        self.physicsBody?.isDynamic = true;
        self.physicsBody?.restitution = 0
        self.physicsBody?.allowsRotation = false;
        
        self.physicsBody?.categoryBitMask = ColliderType.Poo;
        self.physicsBody?.collisionBitMask = ColliderType.Egg;
        self.physicsBody?.contactTestBitMask = ColliderType.Egg;
    }
    
    func fadeOut(innerFunction:@escaping()->Void){
        if alreadyFlower == true{
            return print("Already a flower")
        }
        let fadeOut = SKAction.fadeOut(withDuration: 3)
        let lower = SKAction.scale(by: CGFloat(0.1), duration: 3)
        let higher = SKAction.scale(by: CGFloat(10), duration: 3)
        let fadeIn = SKAction.fadeIn(withDuration: 3)
        alreadyFlower = true
        self.run(fadeOut)
        self.run(lower){
            self.texture = SKTexture(imageNamed: "purpleFlower")
            innerFunction()
            self.run(fadeIn)
            self.run(higher)
        }
    }
    
    func flowerDie(){
        let fadeOut = SKAction.fadeOut(withDuration: 3)
        let lower = SKAction.scale(by: CGFloat(0.1), duration: 3)
        alreadyFlower = true
        self.run(fadeOut)
        self.run(lower)
    }
    
}

