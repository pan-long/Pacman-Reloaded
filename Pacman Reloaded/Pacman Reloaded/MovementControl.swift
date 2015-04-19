//
//  MovementControl.swift
//  Pacman Reloaded
//
//  Created by chuyu on 29/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

protocol MovementControl: class {
    weak var dataSource: MovementDataSource! { get set }
    weak var movableObject: MovableObject! { get set }

    init(movableObject: MovableObject)
    
    // Change the direction of movable object
    func update()
    
    // Reset the movement control
    func reset()
}

protocol MovementDataSource: class {
    func getPacmans() -> [MovableObject]
    func getBlinkys() -> [MovableObject]
}
