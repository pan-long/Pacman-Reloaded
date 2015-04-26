//
//  AIMovementControl.swift
//  Pacman Reloaded
//
//  Created by chuyu on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

enum GhostMovementMode {
    case Chase, Scatter, Frightened
    
    var str: String {
        switch self {
        case .Chase:
            return "Chase"
        case .Scatter:
            return "Scatter"
        default:
            return "Frightened"
        }
    }
}

class AIMovementControl: MovementControl {
    weak var movableObject: MovableObject!
    weak var dataSource: MovementDataSource!
    
    // counts the number of frames
    private var counter = 0
    
    private var currentMode = GhostMovementMode.Scatter
    private var currentModeDuration = 0
    private var stepsSinceUpdate: Int
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
        self.stepsSinceUpdate = Constants.AIMovementControl.UpdateBuffer
    }
    
    // MARK: Update for movement control
    
    func update() {
        let ghost = movableObject as Ghost
        
        // Ghost moves randomly when it's frightened
        if ghost.frightened {
            frightenUpdate()
            return
        }
        
        // If counter exceed indefinite chase -> chase update
        if counter > Constants.AIMovementControl.IndefiniteChase {
            chaseUpdate()
        } else {
            counter += 1
        }
        
        // Update movable object's direction
        switch currentMode {
        case .Scatter:
            if currentModeDuration > Constants.AIMovementControl.ScatterModeDuration {
                changeMode(.Chase)
            } else {
                scatterUpdate()
            }
        case .Chase:
            if currentModeDuration > Constants.AIMovementControl.ChaseModeDuration {
                changeMode(.Scatter)
            } else {
                chaseUpdate()
            }
        default:
            break
        }
        currentModeDuration += 1
    }
    
    private func reverseDirection() {
        movableObject.changeDirection(movableObject.currentDir.opposite)
    }
    
    private func changeMode(nextMode: GhostMovementMode) {
        reverseDirection()
        currentMode = nextMode
        currentModeDuration = 0
    }
    
    // Reset movement configurations when game restarts
    func reset() {
        counter = 0
        currentMode = GhostMovementMode.Scatter
        currentModeDuration = 0
        stepsSinceUpdate = Constants.AIMovementControl.UpdateBuffer
    }
    
    // MARK: AI Frightened Mode
    
    // Movement update for ghosts in frighened mode
    func frightenUpdate() {
        let availableDirections = movableObject.getAvailableDirections()
        if availableDirections.count > 0 {
            let superDice = Int(arc4random_uniform(UInt32(availableDirections.count)))
            
            changeDirection(availableDirections[superDice])
        } else {
            forceReverse()
        }
    }
    
    // MARK: AI Scatter Mode
    
    // Movement update for ghosts in scatter mode
    func scatterUpdate() {
        let availableDirections = movableObject.getAvailableDirections()
        var nextDirection: Direction!
        
        if availableDirections.isEmpty {
            forceReverse()
        } else {
            var minDistanceFromHome: Double = Constants.AIMovementControl.MaxDistance
            
            for direction in availableDirections {
                let distance = calculateDistance(
                    movableObject.getNextPosition(direction, offset: 1),
                    secondPostion: getHome())
                
                if distance < minDistanceFromHome {
                    minDistanceFromHome = distance
                    nextDirection = direction
                }
            }
            
            changeDirection(nextDirection)
        }
    }

    // Return home for ghosts in scatter mode
    // Return dummy data for abstract class
    func getHome() -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    // MARK: AI Chase Mode
    
    // Movement update for ghosts in chase mode
    func chaseUpdate() {
        let availableDirections = movableObject.getAvailableDirections()
        var nextDirection: Direction
        
        if availableDirections.isEmpty {
            forceReverse()
        } else {
            nextDirection = availableDirections[0]
            
            var minDistanceToPacman: Double = Constants.AIMovementControl.MaxDistance
            
            for direction in availableDirections {
                for pacman in dataSource.getPacmans() {
                    let distance = calculateDistance(
                        movableObject.getNextPosition(direction, offset: 1),
                        secondPostion: getChaseTarget(pacman))
                    
                    if distance < minDistanceToPacman {
                        minDistanceToPacman = distance
                        nextDirection = direction
                    }
                }
            }
            
            changeDirection(nextDirection)
        }
    }
    
    // Return dummy data for abstract class
    func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    // MARK: Update utility
    
    private func calculateDistance(firstPostion: CGPoint, secondPostion: CGPoint) -> Double  {
        let distanceX = Double(firstPostion.x) - Double(secondPostion.x)
        let distanceY = Double(firstPostion.y) - Double(secondPostion.y)
        return sqrt(distanceX * distanceX + distanceY * distanceY)
    }
    
    private func isUpdateFrame() -> Bool {
        return stepsSinceUpdate >= Constants.AIMovementControl.UpdateBuffer
    }
    
    private func changeDirection(newDirection: Direction) {
        // only update direction when the ghost is blocked
        // or when there are available directions that can be updated
        if movableObject.currentDir == .None ||
            (isUpdateFrame() && newDirection != movableObject.currentDir) {
            movableObject.changeDirection(newDirection)
            stepsSinceUpdate = 0
        } else {
            stepsSinceUpdate += 1
        }
    }
    
    private func forceReverse() {
        let direction = movableObject.currentDir != .None ? movableObject.currentDir : movableObject.previousDir
        movableObject.changeDirection(direction.opposite)
        stepsSinceUpdate = 0
    }
}

class BlinkyAIMovememntControl: AIMovementControl {
    override func getHome() -> CGPoint {
        return CGPoint(
            x: Constants.AIMovementControl.GameSceneMaxX,
            y: Constants.AIMovementControl.GameSceneMaxY)
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return visibleObject.position
    }
}

class PinkyAIMovementControl: AIMovementControl {
    private let PinkyChaseOffset: CGFloat = 4
    
    override func getHome() -> CGPoint {
        return CGPoint(
            x: Constants.AIMovementControl.GameSceneMinX,
            y: Constants.AIMovementControl.GameSceneMaxY)
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        let chaseTarget = visibleObject.getNextPosition(
            visibleObject.currentDir,
            offset: PinkyChaseOffset )
        
        return chaseTarget
    }
}

class InkyAIMovementControl: AIMovementControl {
    private let InkyChaseOffset: CGFloat = 4
    
    override func getHome() -> CGPoint {
        return CGPoint(
            x: Constants.AIMovementControl.GameSceneMaxX,
            y: Constants.AIMovementControl.GameSceneMinY)
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        let offsetPosition = visibleObject.getNextPosition(
            visibleObject.currentDir,
            offset: InkyChaseOffset)
        let blinkys = dataSource.getBlinkys()
        
        var chaseTarget = visibleObject.position
        var minDistance = Constants.AIMovementControl.MaxDistance
        for blinky in blinkys {
            var blinkyPosition = blinky.position
            let blinkyTarget = CGPoint(
                x: blinkyPosition.x + 2 * (offsetPosition.x - blinkyPosition.x),
                y: blinkyPosition.y + 2 * (offsetPosition.y - blinkyPosition.y))
            let blinkyTargetDistance = calculateDistance(
                movableObject.position,
                secondPostion: blinkyTarget)
            
            if  blinkyTargetDistance < minDistance {
                minDistance = blinkyTargetDistance
                chaseTarget = blinkyTarget
            }
        }
        
        return chaseTarget
    }
}

class ClydeAIMovementControl: AIMovementControl {
    private let ClydeSafetyCoefficient: Double = 8
    
    override func getHome() -> CGPoint {
        return CGPoint(
            x: Constants.AIMovementControl.GameSceneMinX,
            y: Constants.AIMovementControl.GameSceneMinY)
    }
    
    override func chaseUpdate() {
        let availableDirections = movableObject.getAvailableDirections()
        var nextDirection: Direction!
        
        if availableDirections.isEmpty {
            forceReverse()
        } else {
            var minDistanceToPacman = Constants.AIMovementControl.MaxDistance
            
            for direction in availableDirections {
                for pacman in dataSource.getPacmans() {
                    let distance = calculateDistance(
                        movableObject.getNextPosition(direction, offset: 1),
                        secondPostion: getChaseTarget(pacman))
                    
                    // Clyde turns into scatter mode when it is close to pacman
                    if distance < ClydeSafetyCoefficient * Double(movableObject.speed) {
                        scatterUpdate()
                        return
                    }
                    
                    if distance < minDistanceToPacman {
                        minDistanceToPacman = distance
                        nextDirection = direction
                    }
                }
            }
            
            changeDirection(nextDirection)
        }
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return visibleObject.position
    }
}
