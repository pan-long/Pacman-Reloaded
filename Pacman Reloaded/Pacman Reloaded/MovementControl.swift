//
//  MovementControl.swift
//  Pacman Reloaded
//
//  Created by chuyu on 29/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

protocol MovementControl {
    var dataSource: MovementDataSource! { get set }
    
    init(movableObject: MovableObject)
    
    // Change the direction of movable object
    func update()
    
    // Reset the movement control
    func reset()
}


