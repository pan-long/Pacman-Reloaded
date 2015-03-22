//
//  Pacdot.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class PacDot: Item {
//    required override init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    init(SKS rect: CGRect) {
        let location = CGPoint(x: -1 * rect.size.width / 2, y: -1 * rect.size.height / 2 )
        let newRect = CGRect(origin: location, size: rect.size)
        super.init(image: "pacdot")
        self.sprite.size = rect.size
        setup(newRect)
    }

    func setup(newRect: CGRect) {

        self.physicsBody = SKPhysicsBody(circleOfRadius: newRect.size.width / 2  )

        self.physicsBody?.categoryBitMask = GameObjectType.PacDot
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = GameObjectType.PacMan

        self.zPosition = 90
    }
}
