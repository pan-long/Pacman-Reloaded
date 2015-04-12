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
    private let INDEFINITE_CHASE = 2100
    private let CHASE_MODE_DURATION = 400
    private let SCATTER_MODE_DURATION = 100
    
    private let GAME_SCENE_MIN_X: CGFloat = 0
    private let GAME_SCENE_MIN_Y: CGFloat = 0
    private let GAME_SCENE_MAX_X = Constants.GameScene.GridWidth  * CGFloat(Constants.GameScene.NumberOfColumns)
    private let GAME_SCENE_MAX_Y = Constants.GameScene.GridHeight * CGFloat(Constants.GameScene.NumberOfRows)
    
    weak var movableObject: MovableObject!
    weak var dataSource: MovementDataSource!
    
    private var counter = 0
    private var currentMode = GhostMovementMode.Scatter
    private var currentModeDuration = 0
    private var shouldUpdate = true
    
    required init(movableObject: MovableObject) {
        self.movableObject = movableObject
    }
    
    // MARK: Update for movement control
    
    func update() {
        if isUpdateFrame() {
            let ghost = movableObject as Ghost
            
            // Ghost moves randomly when it's frightened
            if ghost.frightened {
                frightenUpdate()
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
                    changeMode(.Chase)
                } else {
                    scatterUpdate()
                }
            case .Chase:
                if currentModeDuration > CHASE_MODE_DURATION {
                    changeMode(.Scatter)
                } else {
                    chaseUpdate()
                }
            default:
                break
            }
            currentModeDuration += 1
        }
    }
    
    private func isUpdateFrame() -> Bool {
        shouldUpdate = !shouldUpdate
        return shouldUpdate
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
        shouldUpdate = true
    }
    
    // MARK: AI Frightened Mode
    
    func frightenUpdate() {
        let availableDirections = movableObject.getAvailableDirections()
        if availableDirections.count > 0 {
            let superDice = Int(arc4random_uniform(UInt32(availableDirections.count)))
            
            movableObject.changeDirection(availableDirections[superDice])
        }
    }
    
    // MARK: AI Scatter Mode
    
    func scatterUpdate() {
        let availableDirections = movableObject.getAvailableDirections()
        var nextDirection: Direction
        
        if availableDirections.isEmpty {
            nextDirection = .None
        } else {
            nextDirection = availableDirections[0]
        }
        
        var minDistanceFromHome: Double = 100000
        
        for direction in availableDirections {
            let distance = calculateDistance(
                movableObject.getNextPosition(direction, offset: 1),
                secondPostion: getHome())
            
            if distance < minDistanceFromHome {
                minDistanceFromHome = distance
                nextDirection = direction
            }
        }
        
        movableObject.changeDirection(nextDirection)
    }

    
    func getHome() -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    // MARK: AI Chase Mode
    
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
                    movableObject.getNextPosition(direction, offset: 1),
                    secondPostion: getChaseTarget(pacman))
                
                if distance < minDistanceToPacman {
                    minDistanceToPacman = distance
                    nextDirection = direction
                }
            }
        }
        
        movableObject.changeDirection(nextDirection)
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
        return CGPoint(x: GAME_SCENE_MAX_X, y: GAME_SCENE_MAX_Y)
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return visibleObject.position
    }
}

class PinkyAIMovementControl: AIMovementControl {
    private let PINKY_CHASE_OFFSET: CGFloat = 4
    
    override func getHome() -> CGPoint {
        return CGPoint(x: GAME_SCENE_MIN_X, y: GAME_SCENE_MAX_Y)
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
        return CGPoint(x: GAME_SCENE_MAX_X, y: GAME_SCENE_MIN_Y)
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        let offsetPosition = visibleObject.getNextPosition(
            visibleObject.currentDir,
            offset: INKY_CHASE_OFFSET)
        let blinkyPosition = dataSource.getBlinky().position
        let chaseTarget = CGPoint(
            x: blinkyPosition.x + 2 * (offsetPosition.x - blinkyPosition.x),
            y: blinkyPosition.y + 2 * (offsetPosition.y - blinkyPosition.y))
        
        return chaseTarget
    }
}

class ClydeAIMovememntControl: AIMovementControl {
    override func getHome() -> CGPoint {
        return CGPoint(x: GAME_SCENE_MIN_X, y: GAME_SCENE_MIN_Y)
    }
    
    override func getChaseTarget(visibleObject: MovableObject) -> CGPoint {
        return visibleObject.position
    }
}
