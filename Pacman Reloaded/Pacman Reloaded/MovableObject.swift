//
//  MovableObject.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class MovableObject: GameObject {
    var currentDir = Direction.Right // TODO
    var requestedDir = Direction.None

    var currentSpeed: CGFloat = 10.0

    func changeDirection(newDirection: Direction) {
        currentDir = newDirection
        self.sprite.zRotation = CGFloat(currentDir.getRotation())
    }

    func update() {
        switch currentDir {
        case .Right:
            self.position = CGPoint(
                x: self.position.x + currentSpeed,
                y: self.position.y
            )
        case .Left:
            self.position = CGPoint(
                x: self.position.x - currentSpeed,
                y: self.position.y
            )
        case .Down:
            self.position = CGPoint(
                x: self.position.x,
                y: self.position.y - currentSpeed
            )
        case .Up:
            self.position = CGPoint(
                x: self.position.x,
                y: self.position.y + currentSpeed
            )
        case .None:
            return
        }
    }
}
