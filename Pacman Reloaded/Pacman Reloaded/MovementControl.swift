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
    // Data source to get other objects in the game
    weak var dataSource: MovementDataSource! { get set }
    // The object that is controlled by `self`
    weak var movableObject: MovableObject! { get set }

    // setup the movement controller to control a target
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
