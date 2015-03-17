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
    convenience init(position: CGPoint) {
        self.init()
        self.position = position
    }
}
