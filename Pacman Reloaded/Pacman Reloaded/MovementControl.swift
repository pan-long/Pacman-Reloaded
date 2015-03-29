//
//  MovementControl.swift
//  Pacman Reloaded
//
//  Created by chuyu on 29/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation

protocol MovementControl {
    var dataSource: MovementDataSource! { get set }
    
    init(movableObject: MovableObject)
    func update()
}

class AIMovementControl: MovementControl {
    private let movableObject: MovableObject!
    var dataSource: MovementDataSource!
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
    }
    
    func update() {
        movableObject.changeDirection(Direction.getRandomDirection())
    }
}

//class GestureMovementControl: MovementControl {
//    
//}