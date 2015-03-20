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
    convenience init() {
        self.init(image: "pacman")
        self.sprite.physicsBody?.categoryBitMask = GameObjectType.PacMan
        self.sprite.physicsBody?.contactTestBitMask = GameObjectType.Ghost
        setupAnimationSequence()
    }

    func setupAnimationSequence() {
        var atlas = SKTextureAtlas(named: "pacman")
        var textures: [SKTexture] = []
        var filenames = ["pacman01", "pacman00"]
        for name in filenames {
            textures.append(atlas.textureNamed(name))
        }

        var animation = SKAction.animateWithTextures(textures, timePerFrame: 1/8, resize: false, restore: true)

        self.sprite.runAction(SKAction.repeatActionForever(animation))

    }

    
}
