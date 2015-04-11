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
    private let movableObject: MovableObject
    
    var dataSource: MovementDataSource!
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
    }
    
    func update() {
    }
}