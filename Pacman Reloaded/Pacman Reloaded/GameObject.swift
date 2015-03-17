//
//  GameObject.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class GameObject: SKSpriteNode {
    convenience init(image: String) {
        self.init(imageNamed: image)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
    }
}
