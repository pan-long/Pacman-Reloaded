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
        
        pacman.position = CGPoint(x: size.width/2 - pacman.sprite.size.width/2,
            y: size.height/2 - pacman.sprite.size.height/2)
        
        addChild(pacman)

        var swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        var swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight:")
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        var swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeUp:")
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        var swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDown:")
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
    }

    func swipeLeft(sender: UISwipeGestureRecognizer) {
        pacman.changeDirection(.Left)
    }


    func swipeRight(sender: UISwipeGestureRecognizer) {
        pacman.changeDirection(.Right)
    }


    func swipeUp(sender: UISwipeGestureRecognizer) {
        pacman.changeDirection(.Up)
    }


    func swipeDown(sender: UISwipeGestureRecognizer) {
        pacman.changeDirection(.Down)
    }



   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        pacman.update()
    }
}
