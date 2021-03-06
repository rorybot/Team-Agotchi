//
//  VisualEgg.swift
//  Tamagotchi
//
//  Created by MacBook Pro on 09/11/2017.
//  Copyright © 2017 Tammo Team. All rights reserved.
//

import Foundation
import SpriteKit

struct ColliderType {
    static let Egg: UInt32 = 1;
    static let World: UInt32 = 2;
    static let Hat: UInt32 = 3;
    static let Poo: UInt32 = 4;
}

class VisualEgg: SKSpriteNode {
    
    var eggAnimationAction = SKAction();
    
    var TextureAtlas = SKTextureAtlas()
    var TextureArray = [SKTexture]()
    
    
    func initialize(){
        self.name = "visualEggInstance"
        self.size = CGSize(width:200.0, height: 200.0)
         self.setScale(1)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint(x: 0, y: -280)
        self.zPosition = 7;
        self.texture = SKTexture(imageNamed: "1276572-200.png")
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size);
        self.physicsBody?.affectedByGravity = true;
        self.physicsBody?.isDynamic = true;
        self.physicsBody?.restitution = 0.5
        self.physicsBody?.allowsRotation = false;
        self.physicsBody?.categoryBitMask = ColliderType.Egg;
        self.physicsBody?.collisionBitMask = ColliderType.Hat;
        self.physicsBody?.contactTestBitMask = ColliderType.Egg;
        
    }
    
    func crackingArray(){
        TextureAtlas = SKTextureAtlas(named: "Cracking")
        for i in 0...TextureAtlas.textureNames.count{
            var Name = "crack\(i).png"
            TextureArray.append(SKTexture(imageNamed: Name))
        }
    }
    
    func jump() {
        self.physicsBody?.velocity = CGVector(dx:0, dy:50)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 400))

    }
    
    func crack(innerFunction:@escaping()->Void){
        crackingArray()
        let goLeft = SKAction.rotate(toAngle: CGFloat(-Double.pi/6), duration: 0.5)
        let goRight = SKAction.rotate(toAngle: CGFloat(Double.pi/6), duration: 0.5)
        let sequence = SKAction.sequence([goLeft,goRight])
        let wobble = SKAction.repeat(sequence, count: 4)
        let returnToCenter = SKAction.rotate(toAngle:CGFloat(-Double.pi*2),duration:0.5)
        self.run(wobble){
            self.run(returnToCenter){
                self.size = CGSize(width:200.0, height: 200.0)
                self.run(SKAction.animate(with: self.TextureArray, timePerFrame:1)){
                    self.removeFromParent()
                    innerFunction()
                    }
                }
            }
    }
    
    func hatEgg(){
        self.texture = SKTexture(imageNamed: "eggWithHat.png")
        self.size = CGSize(width:200.0, height: 300.0)
        self.physicsBody = SKPhysicsBody(texture: (self.texture)!, size: (self.size));
    }
    
    
    
}

