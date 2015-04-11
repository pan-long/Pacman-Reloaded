//
//  AIMovementControl.swift
//  Pacman Reloaded
//
//  Created by chuyu on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

enum MovementMode {
    case Chase, Scatter, Frightened
}

class AIMovementControl: MovementControl {
    private let INDEFINITE_CHASE = 2800
    private let CHASE_MODE_DURATION = 400
    private let SCATTER_MODE_DURATION = 200
    
    weak var movableObject: MovableObject!
    weak var dataSource: MovementDataSource!
    
    private var counter = 1
    private var currentMode = MovementMode.Scatter
    private var currentModeDuration = 0
    private var shouldUpdate = true
    
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
        var nextDirection: Direction

        if availableDirections.isEmpty {
            nextDirection = .None
        } else {
             nextDirection = availableDirections[0]
        }

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

    private func isUpdateFrame() -> Bool {
        shouldUpdate = !shouldUpdate
        return shouldUpdate
    }
    
    func update() {
        if isUpdateFrame() {
            let ghost = movableObject as Ghost
            
            
            // TODO: check frighten mode
            
            // If counter exceed indefinite chase -> chase update
            counter += 1
            if counter >= INDEFINITE_CHASE {
                chaseUpdate()
            }
            
            // Update movable object's direction
            switch currentMode {
            case .Scatter:
                scatterUpdate()
                currentModeDuration += 1
                if currentModeDuration >= SCATTER_MODE_DURATION {
                    println("Chase Mode")
                    currentMode = .Chase
                    currentModeDuration = 0
                }
            case .Chase:
                chaseUpdate()
                currentModeDuration += 1
                if currentModeDuration >= CHASE_MODE_DURATION {
                    println("Scatter Mode")
                    currentMode = .Scatter
                    currentModeDuration = 0
                }
            default:
                break
            }
        }
    }
}

class BlinkyAIMovememntControl: AIMovementControl {
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return visibleObject.position
    }
}

class PinkyAIMovementControl: AIMovementControl {
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
//        var chaseTarget: CGPoint
//        switch visibleObject.currentDir {
//        case .Up:
//            return CGPoint(visibleObject.position.x + 3 * )
//        }
//        return chaseTarget: CGPoint
        return visibleObject.position
    }
}

class InkyAIMovememntControl: AIMovementControl {
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return visibleObject.position
    }
}

class ClydeAIMovememntControl: AIMovementControl {
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return visibleObject.position
    }
}
