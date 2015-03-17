//
//  Pacman.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class PacMan: MovableObject {
    convenience override init() {
        self.init(image: "pacman")
        self.physicsBody?.categoryBitMask = GameObjectType.PacMan
        self.physicsBody?.contactTestBitMask = GameObjectType.Ghost
    }
}
