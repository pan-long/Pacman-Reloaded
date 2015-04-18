//
//  GameObject.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class GameObject: SKNode {
    var objectId: Int?
    var sprite: SKSpriteNode

    init(image: String) {
        self.sprite = SKSpriteNode(imageNamed: image)
        super.init()
        self.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        addChild(sprite)
    }
    
    convenience init(id: Int, image: String) {
        self.init(image: image)
        
        objectId = id
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset() {
        
    }
}
