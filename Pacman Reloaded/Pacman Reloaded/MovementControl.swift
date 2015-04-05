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
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
    }
    
    func update() {
        let availableDirections = movableObject.getAvailableDirections()
        let superDice = random() % availableDirections.count
        println("ghost: \(availableDirections.count)")
            
        movableObject.changeDirection(availableDirections[superDice])
    }
}

class BlinkyAIMovememntControl: AIMovementControl {
    var counter = 0
    
    private func calculateDistance(firstPostion: CGPoint, secondPostion: CGPoint) -> Double  {
        let distanceX = Double(firstPostion.x) - Double(secondPostion.x)
        let distanceY = Double(firstPostion.y) - Double(secondPostion.y)
        return sqrt(distanceX * distanceX + distanceY * distanceY)
    }
    
    override func update() {
        counter = counter + 1
        if counter > 5 {
            
            let availableDirections = movableObject.getAvailableDirections()
            var nextDirection = availableDirections[0]
            
            if availableDirections.count > 1 {
                var minDistanceToPacman: Double = 100000
                
                for direction in availableDirections {
                    for visibleObject in dataSource.getVisibleObjects() {
                        let distance = calculateDistance(
                            movableObject.getNextPosition(direction),
                            secondPostion: visibleObject.position)
                        
                        println("\(direction.str) \(distance)")
                        if distance < minDistanceToPacman {
                            minDistanceToPacman = distance
                            nextDirection = direction
                        }
                    }
                }
                
                println("\(nextDirection.str)")
                
                movableObject.changeDirection(nextDirection)
            } else {
                movableObject.changeDirection(nextDirection)
            }
        }
    }
    
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