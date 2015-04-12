//
//  GestureMovementControl.swift
//  Pacman Reloaded
//
//  Created by chuyu on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class GestureMovementControl: NSObject, MovementControl{
    weak var dataSource: MovementDataSource!
    weak var movableObject: MovableObject!

    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
    }
    
    func update() {
    }
    
    func reset() {
    }
    
    func swipeLeft(sender: UISwipeGestureRecognizer) {
        movableObject.changeDirection(.Left)
    }
    
    func swipeRight(sender: UISwipeGestureRecognizer) {
        movableObject.changeDirection(.Right)
    }
    
    func swipeUp(sender: UISwipeGestureRecognizer) {
        movableObject.changeDirection(.Up)
    }
    
    func swipeDown(sender: UISwipeGestureRecognizer) {
        movableObject.changeDirection(.Down)
    }
}