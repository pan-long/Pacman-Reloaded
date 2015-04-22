//
//  Boundary.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 22/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

private var Texture = SKTexture(imageNamed: Constants.GameScene.BoundaryImage)

class Boundary: SKNode {
    init(size: CGSize, isExterior: Bool) {
        super.init()
        
        let location = CGPoint(x: -1 * size.width / 2, y: -1 * size.height / 2 )
        let newRect = CGRect(origin: location, size: size)
        
        setup(size, rect: newRect, isExterior: isExterior)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setup(size:CGSize, rect: CGRect, isExterior: Bool) {

        let sprite = SKSpriteNode(texture: Texture, size: size)

        addChild(sprite)

        if isExterior {
            self.physicsBody = SKPhysicsBody(edgeLoopFromRect: rect)
        } else {
            self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        }
        self.physicsBody!.dynamic = false
        self.physicsBody!.categoryBitMask = GameObjectType.Boundary
        self.physicsBody!.friction = 0
        self.physicsBody!.allowsRotation = false

        self.zPosition = 100


    }
}

