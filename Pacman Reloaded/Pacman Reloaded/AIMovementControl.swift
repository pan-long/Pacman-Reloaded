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
    
    private var counter = 0
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
            for pacman in dataSource.getPacmans() {
                let distance = calculateDistance(
                    movableObject.getNextPosition(direction),
                    secondPostion: getChaseTarget(pacman))
                
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
    
    private func reverseDirection() {
        movableObject.changeDirection(movableObject.currentDir.opposite)
    }
    
    func reset() {
        counter = 0
        currentMode = MovementMode.Scatter
        currentModeDuration = 0
        shouldUpdate = true
    }
    
    func update() {
        if isUpdateFrame() {
            let ghost = movableObject as Ghost
            
            // Ghost moves randomly when it's frightened
            if ghost.frightened {
                scatterUpdate()
                return
            }
            
            // If counter exceed indefinite chase -> chase update
            if counter > INDEFINITE_CHASE {
                println("Indefinite chase")
                chaseUpdate()
            }
            counter += 1
            
            // Update movable object's direction
            switch currentMode {
            case .Scatter:
                if currentModeDuration > SCATTER_MODE_DURATION {
                    println("Chase Mode")
                    reverseDirection()
                    currentMode = .Chase
                    currentModeDuration = 0
                } else {
                    scatterUpdate()
                    currentModeDuration += 1
                }
            case .Chase:
                if currentModeDuration > CHASE_MODE_DURATION {
                    println("Scatter Mode")
                    reverseDirection()
                    currentMode = .Scatter
                    currentModeDuration = 0
                } else {
                    chaseUpdate()
                    currentModeDuration += 1
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
        var chaseTarget: CGPoint
        let targetSpeed = visibleObject.currentSpeed
        let targetDir = visibleObject.currentDir != .None ?
            visibleObject.currentDir : visibleObject.previousDir
        
        switch visibleObject.currentDir {
        case .Up:
            chaseTarget = CGPoint(
                x: visibleObject.position.x - 4 * targetSpeed,
                y: visibleObject.position.y + 4 * targetSpeed
            )
        case .Down:
            chaseTarget = CGPoint(
                x: visibleObject.position.x,
                y: visibleObject.position.y - 4 * targetSpeed
            )
        case .Left:
            chaseTarget = CGPoint(
                x: visibleObject.position.x - 4 * targetSpeed,
                y: visibleObject.position.y
            )
        default:
            chaseTarget = CGPoint(
                x: visibleObject.position.x + 4 * targetSpeed,
                y: visibleObject.position.y
            )
        }
        return chaseTarget
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
