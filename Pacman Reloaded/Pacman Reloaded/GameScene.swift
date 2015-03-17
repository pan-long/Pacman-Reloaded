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
    let pacman = PacMan()
    
    override func didMoveToView(view: SKView) {
        physicsWorld.gravity = CGVectorMake(0, 0)
        backgroundColor = SKColor.whiteColor()
        
        pacman.position = CGPoint(x: size.width/2 - pacman.size.width/2,
            y: size.height/2 - pacman.size.height/2)
        
        addChild(pacman)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        // TODO Refactor into constants.
        let movePacman = SKAction.moveTo(touchLocation, duration: 0.5)
        pacman.runAction(SKAction.sequence([movePacman]))
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
