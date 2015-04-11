//
//  Ghost.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation

struct GhostName {
    let GHOST_NAME_BLINKY = "BLINKY"
    let GHOST_NAME_CLYDE = "CLYDE"
    let GHOST_NAME_INKY = "INKY"
    let GHOST_NAME_PINKY = "PINKY"
}

class Ghost: MovableObject {
    
    convenience init() {
        self.init(image: "ghost-red-special")
        self.physicsBody?.categoryBitMask = GameObjectType.Ghost
        self.physicsBody?.contactTestBitMask = GameObjectType.PacMan | GameObjectType.Boundary
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody!.dynamic = true
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0 //bouncy
        self.physicsBody!.allowsRotation = false
        
        self.currentSpeed = Constants.Ghost.speed
    }
}
