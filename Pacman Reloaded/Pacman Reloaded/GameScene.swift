//
//  GameScene.swift
//  Pacman Reloaded
//
//  Created by panlong on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // Assume there is only one pacman for now.
    // TODO
    let pacman = SKSpriteNode(imageNamed: "pacman")
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = SKColor.whiteColor()
        
        pacman.position = CGPoint(x: size.width/2 - pacman.size.width/2,
            y: size.height/2 - pacman.size.height/2)
        
        addChild(pacman)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
