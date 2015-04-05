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
    func update()
}

class AIMovementControl: MovementControl {
    private let movableObject: MovableObject!
    var dataSource: MovementDataSource!
    var counter = 0
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
    }
    
    func update() {
        let availableDirections = movableObject.getAvailableDirections()
        if availableDirections.count > 0 {
            let superDice = random() % availableDirections.count
            
            movableObject.changeDirection(availableDirections[superDice])
        } else {
            //println("WTF")
        }
    }
}

class BlinkyAIMovememntControl: AIMovementControl {
    
//    required init(movableObject: MovableObject) {
//        super.init(movableObject: movableObject)
//    }
    
//    override func update() {
//        let availableDirections = movableObject.getAvailableDirections()
//        let superDice = random() % availableDirections.count
//        
//        movableObject.changeDirection(availableDirections[superDice])
//    }
    
    
}

class GestureMovementControl: NSObject, MovementControl{
    private let movableObject: MovableObject!
    var dataSource: MovementDataSource!
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
    }
    
    func update() {
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