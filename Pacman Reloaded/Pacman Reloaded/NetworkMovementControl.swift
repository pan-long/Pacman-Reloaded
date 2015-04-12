//
//  NetworkMovementControl.swift
//  Pacman Reloaded
//
//  Created by panlong on 11/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class NetworkMovementControl: MovementControl {
    weak var movableObject: MovableObject!
    
    weak var dataSource: MovementDataSource!
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
    }
    
    func update() {
    }
    
    func reset() {
    }
    
    func changeDirection(direction: Direction) {
        movableObject.changeDirection(direction)
    }
    
    func correctPosition(position: CGPoint) {
        movableObject.position = position
    }
}