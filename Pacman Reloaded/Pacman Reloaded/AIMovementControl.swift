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
    private let MAX_DISTANCE: Double = 10000
    private let UPDATE_BUFFER: Int = 4
    
    weak var movableObject: MovableObject!
    weak var dataSource: MovementDataSource!
    
    private var counter = 0
    private var currentMode = GhostMovementMode.Scatter
    private var currentModeDuration = 0
    private var stepsSinceUpdate: Int
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
        self.stepsSinceUpdate = UPDATE_BUFFER
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
        if counter > Constants.AIMovementControl.INDEFINITE_CHASE {
            println("Indefinite chase")
            chaseUpdate()
        }
        counter += 1
        
        // Update movable object's direction
        switch currentMode {
        case .Scatter:
            if currentModeDuration > Constants.AIMovementControl.SCATTER_MODE_DURATION {
                changeMode(.Chase)
            } else {
                scatterUpdate()
            }
        case .Chase:
            if currentModeDuration > Constants.AIMovementControl.CHASE_MODE_DURATION {
                changeMode(.Scatter)
            } else {
                chaseUpdate()
            }
        default:
            break
        }
        currentModeDuration += 1
    }
    
    private func isUpdateFrame() -> Bool {
        return stepsSinceUpdate >= UPDATE_BUFFER
    }
    
    private func reverseDirection() {
        movableObject.changeDirection(movableObject.currentDir.opposite)
    }
    
    private func changeMode(nextMode: GhostMovementMode) {
        println("\(nextMode.str)")
        reverseDirection()
        currentMode = nextMode
        currentModeDuration = 0
    }
    
    func reset() {
        counter = 0
        currentMode = GhostMovementMode.Scatter
        currentModeDuration = 0
        stepsSinceUpdate = UPDATE_BUFFER
    }
    
    private func changeDirection(newDirection: Direction) {
        if newDirection != movableObject.currentDir &&
            (isUpdateFrame() || movableObject.currentDir == .None) {
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
    
    // MARK: AI Frightened Mode
    
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
    
    func scatterUpdate() {
        let availableDirections = movableObject.getAvailableDirections()
        var nextDirection: Direction
        
        if availableDirections.isEmpty {
            forceReverse()
        } else {
            nextDirection = availableDirections[0]
        
            var minDistanceFromHome: Double = MAX_DISTANCE
            
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

    
    func getHome() -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    // MARK: AI Chase Mode
    
    func chaseUpdate() {
        let availableDirections = movableObject.getAvailableDirections()
        var nextDirection: Direction
        
        if availableDirections.isEmpty {
            forceReverse()
        } else {
            nextDirection = availableDirections[0]
            
            var minDistanceToPacman: Double = MAX_DISTANCE
            
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
    
    func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    private func calculateDistance(firstPostion: CGPoint, secondPostion: CGPoint) -> Double  {
        let distanceX = Double(firstPostion.x) - Double(secondPostion.x)
        let distanceY = Double(firstPostion.y) - Double(secondPostion.y)
        return sqrt(distanceX * distanceX + distanceY * distanceY)
    }
}

class BlinkyAIMovememntControl: AIMovementControl {
    override func getHome() -> CGPoint {
        return CGPoint(
            x: Constants.AIMovementControl.GAME_SCENE_MAX_X,
            y: Constants.AIMovementControl.GAME_SCENE_MAX_Y)
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return visibleObject.position
    }
}

class PinkyAIMovementControl: AIMovementControl {
    private let PINKY_CHASE_OFFSET: CGFloat = 4
    
    override func getHome() -> CGPoint {
        return CGPoint(
            x: Constants.AIMovementControl.GAME_SCENE_MIN_X,
            y: Constants.AIMovementControl.GAME_SCENE_MAX_Y)
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        let chaseTarget = visibleObject.getNextPosition(
            visibleObject.currentDir,
            offset: PINKY_CHASE_OFFSET )
        
        return chaseTarget
    }
}

class InkyAIMovememntControl: AIMovementControl {
    private let INKY_CHASE_OFFSET: CGFloat = 4
    
    override func getHome() -> CGPoint {
        return CGPoint(
            x: Constants.AIMovementControl.GAME_SCENE_MAX_X,
            y: Constants.AIMovementControl.GAME_SCENE_MIN_Y)
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        let offsetPosition = visibleObject.getNextPosition(
            visibleObject.currentDir,
            offset: INKY_CHASE_OFFSET)
        let blinkys = dataSource.getBlinkys()
        
        var chaseTarget = visibleObject.position
        var minDistance = MAX_DISTANCE
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

class ClydeAIMovememntControl: AIMovementControl {
    private let CLYDE_SAFETY_COEFFICIENT: Double = 8
    
    override func getHome() -> CGPoint {
        return CGPoint(
            x: Constants.AIMovementControl.GAME_SCENE_MIN_X,
            y: Constants.AIMovementControl.GAME_SCENE_MIN_Y)
    }
    
    override func chaseUpdate() {
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
                    movableObject.getNextPosition(direction, offset: 1),
                    secondPostion: getChaseTarget(pacman))
                
                // Clyde turns into scatter mode when it is close to pacman
                if distance < CLYDE_SAFETY_COEFFICIENT * Double(movableObject.speed) {
                    scatterUpdate()
                    return
                }
                
                if distance < minDistanceToPacman {
                    minDistanceToPacman = distance
                    nextDirection = direction
                }
            }
        }
        
        movableObject.changeDirection(nextDirection)
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return visibleObject.position
    }
}
