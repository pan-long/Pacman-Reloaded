//
//  Boundary.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 22/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class Boundary: SKNode {
    init(size: CGSize) {
        super.init()
        
        let location = CGPoint(x: -1 * size.width / 2, y: -1 * size.height / 2 )
        let newRect = CGRect(origin: location, size: size)
        
        setup(newRect)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func setup(rect:CGRect) {

        let shape = SKShapeNode(rect: rect, cornerRadius: 19)
        shape.fillColor = SKColor.clearColor()
        shape.strokeColor = SKColor.whiteColor()
        shape.lineWidth = 1

        addChild(shape)

        self.physicsBody = SKPhysicsBody(rectangleOfSize: rect.size)
        self.physicsBody!.dynamic = false
        self.physicsBody!.categoryBitMask = GameObjectType.Boundary
        self.physicsBody!.friction = 0
        self.physicsBody!.allowsRotation = false

        self.zPosition = 100


    }
}

