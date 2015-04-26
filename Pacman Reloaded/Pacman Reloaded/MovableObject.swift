//
//  MovableObject.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

protocol MovementNetworkDelegate: class {
    func objectDirectionChanged(objectId: Int, newDirection: Direction, position: CGPoint)
}

class MovableObject: GameObject {
    // the last available direction, used for AI information
    var previousDir = Direction.None
    // current direction that the player is heading
    var currentDir: Direction = Direction.Default {
        didSet {
            currentDirRaw = currentDir.rawValue
        }
    }
    
    dynamic var currentDirRaw = Direction.Right.rawValue

    // next desired direction that is currently not available
    var requestedDir = Direction.None

    // if the value is 0, the direction is not blocked. Otherwise
    // it shows the number of objects that is on a certain direction
    var blocked = (up: 0, down: 0, left: 0, right: 0)
    var sensors: (up: SKNode?, down: SKNode?, left: SKNode?, right: SKNode?)
    
    var currentSpeed: CGFloat = 5.0
    // distance from center of sensor to center of object
    private var sensorBuffer: CGFloat = 0
    
    weak var networkDelegate: MovementNetworkDelegate?

    init(id: Int, image: String) {
        super.init(id: id, image: image, sizeScale: Constants.MovableObject.SizeScale)
        
        sensorBuffer = self.sprite.size.width * 0.5
        
        sensors.up = SKNode()
        addChild(sensors.up!)
        sensors.up!.position = CGPoint(x:0, y:sensorBuffer)
        createUpSensorPhysicsBody( whileTravellingUpOrDown: false )
        
        sensors.down = SKNode()
        addChild(sensors.down!)
        sensors.down!.position = CGPoint(x:0, y: -sensorBuffer )
        createDownSensorPhysicsBody( whileTravellingUpOrDown: false)
        
        sensors.right = SKNode()
        addChild(sensors.right!)
        sensors.right!.position = CGPoint(x: sensorBuffer, y:0 )
        createRightSensorPhysicsBody( whileTravellingLeftOrRight: true)
        
        sensors.left = SKNode()
        addChild(sensors.left!)
        sensors.left!.position = CGPoint(x: -sensorBuffer, y:0 )
        createLeftSensorPhysicsBody( whileTravellingLeftOrRight: true)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reset() {
        blocked = (up: 0, down: 0, left: 0, right: 0)
        currentSpeed = 5.0
        currentDir = .Right
        requestedDir = .None
        self.changeDirection(.Right) // reset sprite
        super.reset()
    }
    
    // Get the direction that can be turned to, but not including reverse direction
    func getAvailableDirections() -> [Direction] {
        var availableDirections = [Direction]()
        switch currentDir {
        case .Up:
            if blocked.up == 0 {
                availableDirections.append(.Up)
            }
            if blocked.left == 0 {
                availableDirections.append(.Left)
            }
            if blocked.right == 0 {
                availableDirections.append(.Right)
            }
        case .Down:
            if blocked.down == 0 {
                availableDirections.append(.Down)
            }
            if blocked.left == 0 {
                availableDirections.append(.Left)
            }
            if blocked.right == 0 {
                availableDirections.append(.Right)
            }
        case .Left:
            if blocked.up == 0 {
                availableDirections.append(.Up)
            }
            if blocked.down == 0 {
                availableDirections.append(.Down)
            }
            if blocked.left == 0 {
                availableDirections.append(.Left)
            }
        case .Right:
            if blocked.up == 0 {
                availableDirections.append(.Up)
            }
            if blocked.down == 0 {
                availableDirections.append(.Down)
            }
            if blocked.right == 0 {
                availableDirections.append(.Right)
            }
        default:
            if blocked.up == 0 && previousDir != .Down{
                availableDirections.append(.Up)
            }
            if blocked.left == 0 && previousDir != .Right{
                availableDirections.append(.Left)
            }
            if blocked.right == 0 && previousDir != .Left {
                availableDirections.append(.Right)
            }
            if blocked.down == 0 && previousDir != .Up {
                availableDirections.append(.Down)
            }
        }
        return availableDirections
    }

    // change the object to a new direction, if the turn is not
    // possible, the request will be stored and made again on next update cycle
    func changeDirection(newDirection: Direction) {
        var success = true
        var upDown = (newDirection == .Up || newDirection == .Down)
        switch newDirection {
        case .Up:
            if blocked.up > 0 {
                success = false
            } else {
                blocked.down = 0
            }
        case .Down:
            if blocked.down > 0 {
                success = false
            } else {
                blocked.up = 0
            }
        case .Left:
            if blocked.left > 0 {
                success = false
            } else {
                blocked.right = 0
            }
        case .Right:
            if blocked.right > 0 {
                success = false
            } else {
                blocked.left = 0
            }
        default:
            break
        }
        if success {
            self.physicsBody?.dynamic = true
            
            previousDir = currentDir
            currentDir = newDirection
            requestedDir = .None
            
            blocked.up = 0
            blocked.down = 0
            blocked.left = 0
            blocked.right = 0
            
            createUpSensorPhysicsBody(whileTravellingUpOrDown: upDown)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: upDown )
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: !upDown )
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: !upDown )
            
            if let networkDelegate = networkDelegate { // update network that the direction has been changed
                networkDelegate.objectDirectionChanged(objectId, newDirection: newDirection, position: position)
            }
        } else {
            requestedDir = newDirection
        }
    }

    // estimate the next step
    func getNextPosition(direction: Direction, offset: CGFloat) -> CGPoint {        
        var nextPosition : CGPoint
        
        switch direction {
        case .Right:
            nextPosition = CGPoint(
                x: self.position.x + offset * currentSpeed,
                y: self.position.y
            )
        case .Left:
            nextPosition = CGPoint(
                x: self.position.x - offset * currentSpeed,
                y: self.position.y
            )
        case .Down:
            nextPosition = CGPoint(
                x: self.position.x,
                y: self.position.y - offset * currentSpeed
            )
        case .Up:
            nextPosition = CGPoint(
                x: self.position.x,
                y: self.position.y + offset * currentSpeed
            )
        case .None:
            nextPosition = self.position
        }
        
        return nextPosition
    }
    
    func update() {
        self.position = getNextPosition(currentDir, offset: 1)
    }
    
    func backwards() {
        self.position = getNextPosition(currentDir, offset: -1)
    }
    
    // MARK: - SENSORS
    
    private func getForwardSensorLongEdge() -> CGFloat {
        return self.sprite.size.width * 0.8
    }
    
    private func getForwardSensorShortEdge() -> CGFloat {
        return Constants.GameScene.GridWidth - self.sprite.size.width + 2 * (self.currentSpeed - 1)
    }
    
    private func getSideSensorLongEdge() -> CGFloat {
        return Constants.GameScene.GridWidth - 2 * (self.currentSpeed - 1)
    }
    
    private func getSideSensorShortEdge() -> CGFloat {
        return self.sprite.size.height * 0.8
    }

    private func setupSensor(sensor: SKPhysicsBody) {
        sensor.collisionBitMask = 0
        sensor.contactTestBitMask = GameObjectType.Boundary
        sensor.pinned = true
        sensor.allowsRotation = false
    }
    private func createUpSensorPhysicsBody(#whileTravellingUpOrDown:Bool) {
        
        var size:CGSize
        if (whileTravellingUpOrDown == true) {
            size = CGSize(width: getForwardSensorLongEdge(), height: getForwardSensorShortEdge())
        } else {
            size = CGSize(width: getSideSensorLongEdge(), height: getSideSensorShortEdge())
        }
        let bodyUp:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size)
        setupSensor(bodyUp)
        sensors.up!.physicsBody = bodyUp
        sensors.up!.physicsBody?.categoryBitMask = GameObjectType.SensorUp

    }
    
    private func createDownSensorPhysicsBody(#whileTravellingUpOrDown:Bool){
        var size:CGSize
        if (whileTravellingUpOrDown == true) {
            size = CGSize(width: getForwardSensorLongEdge(), height: getForwardSensorShortEdge())
        } else {
            size = CGSize(width: getSideSensorLongEdge(), height: getSideSensorShortEdge())
        }
        let bodyDown:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        setupSensor(bodyDown)
        sensors.down!.physicsBody = bodyDown
        sensors.down!.physicsBody?.categoryBitMask = GameObjectType.SensorDown

        
        
    }
    
    private func createLeftSensorPhysicsBody( #whileTravellingLeftOrRight:Bool){
        
        var size:CGSize
        if (whileTravellingLeftOrRight == true) {
            size = CGSize(width: getForwardSensorShortEdge(), height: getForwardSensorLongEdge())
        } else {
            size = CGSize(width: getSideSensorShortEdge(), height: getSideSensorLongEdge())
        }
        let bodyLeft:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        setupSensor(bodyLeft)
        sensors.left!.physicsBody = bodyLeft
        sensors.left!.physicsBody?.categoryBitMask = GameObjectType.SensorLeft
    }
    
    private func createRightSensorPhysicsBody( #whileTravellingLeftOrRight:Bool){
        var size:CGSize
        if (whileTravellingLeftOrRight == true) {
            size = CGSize(width: getForwardSensorShortEdge(), height: getForwardSensorLongEdge())
        } else {
            size = CGSize(width: getSideSensorShortEdge(), height: getSideSensorLongEdge())
        }
        let bodyRight:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        setupSensor(bodyRight)
        sensors.right!.physicsBody = bodyRight
        sensors.right!.physicsBody?.categoryBitMask = GameObjectType.SensorRight
    }

    // Indicate that one sensor has made new contact with an obstacle
    func sensorContactStart(direction: Direction) {
        switch direction {
        case .Up:
            blocked.up += 1
        case .Down:
            blocked.down += 1
        case .Left:
            blocked.left += 1
        case .Right:
            blocked.right += 1
        default:
            break
        }
        
        if currentDir == direction {
            previousDir = currentDir
            currentDir = .None
            self.physicsBody?.dynamic = false
        }
    }

    // Indicate that one sensor has moved away from one obstacle
    func sensorContactEnd(direction: Direction) {
        switch direction {
        case .Up:
            blocked.up -= 1
        case .Down:
            blocked.down -= 1
        case .Left:
            blocked.left -= 1
        case .Right:
            blocked.right -= 1
        default:
            break
        }
        
        if requestedDir == direction {
            changeDirection(direction)
        }
    }
}
