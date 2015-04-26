//
//  Pacman.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

protocol PacmanScoreNetworkDelegate: class {
    func pacmanScoreUpdated(pacmanId: Int, newScore: Int)
}

class PacMan: MovableObject {
    var invincible = false
    let pacmanDice = Int(arc4random_uniform(UInt32(Constants.PacMan.ImageCount)))
    var score: Int = 0 {
        didSet {
            if let scoreNetworkDelegate = scoreNetworkDelegate {
                scoreNetworkDelegate.pacmanScoreUpdated(objectId, newScore: score)
            }
        }
    }
    
    weak var scoreNetworkDelegate: PacmanScoreNetworkDelegate?

    // Pacman can be set up by ID only, image is fetched from constants file directly
    init(id: Int) {
        super.init(id: id, image: Constants.PacMan.Images[pacmanDice])
        self.physicsBody?.categoryBitMask = GameObjectType.PacMan
        self.physicsBody?.contactTestBitMask = GameObjectType.Ghost | GameObjectType.Boundary | GameObjectType.PacDot
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.dynamic = true
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0 //bouncy
        self.physicsBody!.allowsRotation = false
        setupAnimationSequence()

        self.currentSpeed = Constants.PacMan.Speed
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // reset the score
    override func reset() {
        score = 0
        super.reset()
    }

    override func changeDirection(newDirection: Direction) {
        super.changeDirection(newDirection)
        self.sprite.zRotation = CGFloat(currentDir.getRotation())
        if currentDir == .Left {
            self.sprite.yScale = -1
        } else {
            self.sprite.yScale = 1
        }
    }

    private func setupAnimationSequence() {
        var atlas = SKTextureAtlas(named: Constants.PacMan.Images[pacmanDice])
        var textures: [SKTexture] = []
        var filenames = Constants.PacMan.Filenames[pacmanDice]
        for name in filenames {
            textures.append(atlas.textureNamed(name))
        }

        var animation = SKAction.animateWithTextures(textures, timePerFrame: 1/5, resize: false, restore: true)

        self.sprite.runAction(SKAction.repeatActionForever(animation))

    }
}
