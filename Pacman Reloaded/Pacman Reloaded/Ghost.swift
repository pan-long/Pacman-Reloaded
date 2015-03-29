//
//  Ghost.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation

class Ghost: MovableObject {
    
    convenience init() {
        self.init(image: "ghost-red-special")
        self.physicsBody?.categoryBitMask = GameObjectType.Ghost
        self.physicsBody?.contactTestBitMask = GameObjectType.PacMan | GameObjectType.Boundary
        self.physicsBody!.dynamic = true
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0 //bouncy
        self.physicsBody!.allowsRotation = false
    }
}
