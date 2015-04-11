//
//  Ghost.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class Ghost: MovableObject {
    private var imageName: String = ""

    var frightened: Bool = false {
        didSet {
            updateTexture()
        }
    }


    convenience init(imageName: String) {
        self.init(image: imageName + Constants.Ghost.defaultImageSuffix)
        self.imageName = imageName
        self.physicsBody?.categoryBitMask = GameObjectType.Ghost
        self.physicsBody?.contactTestBitMask = GameObjectType.PacMan | GameObjectType.Boundary
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody!.dynamic = true
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0 //bouncy
        self.physicsBody!.allowsRotation = false
        
        self.currentSpeed = Constants.Ghost.speed
    }

    override func changeDirection(newDirection: Direction) {
        super.changeDirection(newDirection)
        updateTexture()
    }

    private func updateTexture() {
        if self.frightened {
            self.sprite.texture = SKTexture(imageNamed: self.imageName
                + Constants.Ghost.imageSeparator
                + Constants.Ghost.frightenedImageSuffix)
        } else if self.currentDir != .None {
            self.sprite.texture = SKTexture(imageNamed: self.imageName +
                Constants.Ghost.imageSeparator +
                self.currentDir.str.lowercaseString)
        } else {
            self.sprite.texture = SKTexture(imageNamed: self.imageName +
                Constants.Ghost.imageSeparator +
                Direction.Default.str.lowercaseString)

        }
    }

}
