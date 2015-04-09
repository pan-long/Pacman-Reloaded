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

    var isSuper = false

    init(size: CGSize) {
        let location = CGPoint(x: -1 * size.width / 2, y: -1 * size.height / 2 )
        let newRect = CGRect(origin: location, size: size)
        super.init(image: Constants.PacDot.normalPacDotImage)
        self.sprite.size = size
        setup(newRect)
    }

    init(superSize size: CGSize) {
        let location = CGPoint(x: -1 * size.width / 2, y: -1 * size.height / 2 )
        let newRect = CGRect(origin: location, size: size)
        super.init(image: Constants.PacDot.superPacDotImage)
        self.sprite.size = size
        setup(newRect)
        isSuper = true
    }

    func setup(newRect: CGRect) {

        self.physicsBody = SKPhysicsBody(circleOfRadius: newRect.size.width / 2  )

        self.physicsBody?.categoryBitMask = GameObjectType.PacDot
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = GameObjectType.PacMan

        self.zPosition = Constants.PacDot.zPosition
    }
}
