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
    
    var position: CGPoint?
    var direction: Direction?
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
    }
    
    func update() {
        if let position = position {
            movableObject.position = position
            self.position = nil
        }
        
        if let direction = direction {
            movableObject.changeDirection(direction)
            if (movableObject.currentDir != direction) {
                movableObject.backwards()
                movableObject.backwards()
                movableObject.changeDirection(direction)
            }
            self.direction = nil
        }
    }
    
    func reset() {
    }
    
    func changeDirection(direction: Direction) {
        self.direction = direction
    }
    
    func correctPosition(position: CGPoint) {
        self.position = position
    }
}