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
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.blackColor()
        
        pacman.position = CGPoint(x: size.width/2 - pacman.sprite.size.width/2,
            y: size.height/2 - pacman.sprite.size.height/2)
        
        addChild(pacman)

        setupBoundary()
        setupPacDot()

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

    func setupBoundary() {
        self.enumerateChildNodesWithName("boundary") {
            node, stop in
            if let sksBoundary = node as? SKSpriteNode {

                let rect:CGRect = CGRect(origin: sksBoundary.position, size: sksBoundary.size)
                let boundary = Boundary(SKS: rect)
                self.addChild(boundary)
                boundary.position = sksBoundary.position

                sksBoundary.removeFromParent()

            }
        }
    }

    func setupPacDot() {
        self.enumerateChildNodesWithName("pacdot") {
            node, stop in
            if let sks = node as? SKSpriteNode {

                let rect:CGRect = CGRect(origin: sks.position, size: sks.size)
                let pacdot = PacDot(SKS: rect)
                self.addChild(pacdot)
                pacdot.position = sks.position

                sks.removeFromParent()
                
            }
        }
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

extension GameScene: SKPhysicsContactDelegate {

    func didBeginContact(contact: SKPhysicsContact) {

        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch contactMask {

        case GameObjectType.PacMan | GameObjectType.PacDot :
            if let pacdot = contact.bodyA.node as? PacDot {
                pacdot.removeFromParent()
            } else if let pacdot = contact.bodyB.node as? PacDot {
                pacdot.removeFromParent()
            } else {
                println("???")
            }
            pacman.score++
            println(pacman.score)
        default:
            return

        }

    }



    func didEndContact(contact: SKPhysicsContact) {

        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch contactMask {

        case GameObjectType.PacMan | GameObjectType.Boundary:

            println( "is not touching wall")

        default:
            return

        }

    }
}
