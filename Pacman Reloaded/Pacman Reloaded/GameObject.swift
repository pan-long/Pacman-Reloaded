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
    // UID for each object
    let objectId: Int
    // image name of the main sprite
    let image: String
    // object sprite
    var sprite: SKSpriteNode

    // init the object with a given UID, image and a scaling factor for the image
    init(id: Int, image: String, sizeScale: CGFloat) {
        self.objectId = id
        self.image = image
        
        self.sprite = SKSpriteNode(imageNamed: image)
        super.init()
        
        let spriteSize = CGSize(
            width: self.sprite.size.width * sizeScale,
            height: self.sprite.size.height * sizeScale)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: spriteSize)
        addChild(sprite)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset() {
        
    }
}
