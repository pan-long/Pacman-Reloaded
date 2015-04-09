//
//  AIMovementControl.swift
//  Pacman Reloaded
//
//  Created by chuyu on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class AIMovementControl: MovementControl {
    private let movableObject: MovableObject!
    var dataSource: MovementDataSource!
    var counter = 0
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
    }
    
    private func calculateDistance(firstPostion: CGPoint, secondPostion: CGPoint) -> Double  {
        let distanceX = Double(firstPostion.x) - Double(secondPostion.x)
        let distanceY = Double(firstPostion.y) - Double(secondPostion.y)
        return sqrt(distanceX * distanceX + distanceY * distanceY)
    }
    
    func scatterUpdate() {
        let availableDirections = movableObject.getAvailableDirections()
        if availableDirections.count > 0 {
            let superDice = Int(arc4random_uniform(UInt32(availableDirections.count)))

            movableObject.changeDirection(availableDirections[superDice])
        }
    }
    
    func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    func chaseUpdate() {
        let availableDirections = movableObject.getAvailableDirections()
        var nextDirection = availableDirections[0]
        var minDistanceToPacman: Double = 100000
        
        for direction in availableDirections {
            for visibleObject in dataSource.getVisibleObjects() {
                let distance = calculateDistance(
                    movableObject.getNextPosition(direction),
                    secondPostion: getChaseTarget(visibleObject))
                
                if distance < minDistanceToPacman {
                    minDistanceToPacman = distance
                    nextDirection = direction
                }
            }
        }
        
        movableObject.changeDirection(nextDirection)
    }
    
    func update() {
        counter += 1
        println("\(counter)")
        
        switch counter {
        case 1...100:
            scatterUpdate()
        case 101...400:
            chaseUpdate()
        case 401...500:
            scatterUpdate()
        case 501...800:
            chaseUpdate()
        case 801...870:
            scatterUpdate()
        case 871...1500:
            chaseUpdate()
        case 1501...1570:
            scatterUpdate()
        default:
            chaseUpdate()
        }
    }
}

class BlinkyAIMovememntControl: AIMovementControl {
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return visibleObject.position
    }
}
