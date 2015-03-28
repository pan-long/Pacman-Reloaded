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
    var score = 0

    convenience init() {
        self.init(image: "ghost-red-special")
        self.physicsBody?.categoryBitMask = GameObjectType.PacMan
        self.physicsBody?.contactTestBitMask = GameObjectType.Ghost | GameObjectType.Boundary | GameObjectType.PacDot
        self.physicsBody!.dynamic = true
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0 //bouncy
        self.physicsBody!.allowsRotation = false
        // setupAnimationSequence()
    }

    func setupAnimationSequence() {
        var atlas = SKTextureAtlas(named: "pacman-female")
        var textures: [SKTexture] = []
        var filenames = ["pacman-female00", "pacman-female01"]
        for name in filenames {
            textures.append(atlas.textureNamed(name))
        }

        var animation = SKAction.animateWithTextures(textures, timePerFrame: 1/5, resize: false, restore: true)

        self.sprite.runAction(SKAction.repeatActionForever(animation))

    }

    
}
