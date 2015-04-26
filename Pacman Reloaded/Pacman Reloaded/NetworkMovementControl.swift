//
//  NetworkMovementControl.swift
//  Pacman Reloaded
//
//  Created by panlong on 11/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

/**
  * This class controls the movement of movable objects using the data passed from network
**/
class NetworkMovementControl: MovementControl {
    weak var movableObject: MovableObject!
    
    weak var dataSource: MovementDataSource!
    
    // use two local variables to store the changes from network
    // to avoid modifying the properties of movable objects from another thread
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
                // there might be a problem in sensor causing the object unable to change the direction
                // in this case, we will force set the direction
                movableObject.currentDir = direction
                movableObject.requestedDir = .None
                
                // finish other setups of changing direction
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