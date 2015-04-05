//
//  MovableObject.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

class MovableObject: GameObject {
    var previousDir = Direction.None
    var currentDir = Direction.Right
    var requestedDir = Direction.None

    var blocked = (up: 0, down: 0, left: 0, right: 0)
    var sensors: (up: SKNode?, down: SKNode?, left: SKNode?, right: SKNode?)

    var currentSpeed: CGFloat = 5.0
    var sensorBuffer: CGFloat = 0

    override init(image: String) {
        super.init(image: image)

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
            self.sprite.zRotation = CGFloat(currentDir.getRotation())
            if currentDir == .Left {
                self.sprite.yScale = -1
            } else {
                self.sprite.yScale = 1
            }

            blocked.up = 0
            blocked.down = 0
            blocked.left = 0
            blocked.right = 0

            createUpSensorPhysicsBody(whileTravellingUpOrDown: upDown)

            createDownSensorPhysicsBody(whileTravellingUpOrDown: upDown )
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: !upDown )
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: !upDown )

        } else {
            requestedDir = newDirection
        }
    }

    func update() {
        switch currentDir {
        case .Right:
            self.position = CGPoint(
                x: self.position.x + currentSpeed,
                y: self.position.y
            )
        case .Left:
            self.position = CGPoint(
                x: self.position.x - currentSpeed,
                y: self.position.y
            )
        case .Down:
            self.position = CGPoint(
                x: self.position.x,
                y: self.position.y - currentSpeed
            )
        case .Up:
            self.position = CGPoint(
                x: self.position.x,
                y: self.position.y + currentSpeed
            )
        case .None:
            return
        }
    }

    // MARK: - SENSORS

    func createUpSensorPhysicsBody(#whileTravellingUpOrDown:Bool) {

        var size:CGSize
        if (whileTravellingUpOrDown == true) {
            size = CGSize(width: self.sprite.size.width * 0.8, height: 16.6) // tunnel 50 - size 33.3
        } else {
            size = CGSize(width: (self.sprite.size.width + 16.6) * 0.85, height: self.sprite.size.height * 0.8)
        }

        sensors.up!.physicsBody = nil // get rid of any existing physics body
        let bodyUp:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size)
        sensors.up!.physicsBody = bodyUp
        sensors.up!.physicsBody?.categoryBitMask = GameObjectType.SensorUp
        sensors.up!.physicsBody?.collisionBitMask = 0
        sensors.up!.physicsBody?.contactTestBitMask = GameObjectType.Boundary
        sensors.up!.physicsBody?.pinned = true
        sensors.up!.physicsBody?.allowsRotation = false
    }

    func createDownSensorPhysicsBody(#whileTravellingUpOrDown:Bool){
        var size:CGSize
        if (whileTravellingUpOrDown == true) {
            size = CGSize(width: self.sprite.size.width * 0.8, height: 16.6)
        } else {
            size = CGSize(width: (self.sprite.size.width + 16.6) * 0.85, height: self.sprite.size.height * 0.8)
        }
        sensors.down?.physicsBody = nil
        let bodyDown:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        sensors.down!.physicsBody = bodyDown
        sensors.down!.physicsBody?.categoryBitMask = GameObjectType.SensorDown
        sensors.down!.physicsBody?.collisionBitMask = 0
        sensors.down!.physicsBody?.contactTestBitMask = GameObjectType.Boundary
        sensors.down!.physicsBody!.pinned = true
        sensors.down!.physicsBody!.allowsRotation = false


    }

    func createLeftSensorPhysicsBody( #whileTravellingLeftOrRight:Bool){

        var size:CGSize
        if (whileTravellingLeftOrRight == true) {
            size = CGSize(width: 16.6, height: self.sprite.size.width * 0.8)
        } else {
            size = CGSize(width: self.sprite.size.width * 0.8, height: (self.sprite.size.width + 16.6) * 0.85)
        }
        sensors.left?.physicsBody = nil
        let bodyLeft:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        sensors.left!.physicsBody = bodyLeft
        sensors.left!.physicsBody?.categoryBitMask = GameObjectType.SensorLeft
        sensors.left!.physicsBody?.collisionBitMask = 0
        sensors.left!.physicsBody?.contactTestBitMask = GameObjectType.Boundary
        sensors.left!.physicsBody!.pinned = true
        sensors.left!.physicsBody!.allowsRotation = false
    }

    func createRightSensorPhysicsBody( #whileTravellingLeftOrRight:Bool){
        var size:CGSize
        if (whileTravellingLeftOrRight == true) {
            size = CGSize(width: 16.6, height: self.sprite.size.width * 0.8)
        } else {
            size = CGSize(width: self.sprite.size.width * 0.8, height: (self.sprite.size.width + 16.6) * 0.85)
        }
        sensors.right?.physicsBody = nil
        let bodyRight:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        sensors.right!.physicsBody = bodyRight
        sensors.right!.physicsBody?.categoryBitMask = GameObjectType.SensorRight
        sensors.right!.physicsBody?.collisionBitMask = 0
        sensors.right!.physicsBody?.contactTestBitMask = GameObjectType.Boundary
        sensors.right!.physicsBody!.pinned = true
        sensors.right!.physicsBody!.allowsRotation = false
    }

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
        println("left: \(blocked.left), right: \(blocked.right), up: \(blocked.up), down: \(blocked.down)")

        if currentDir == direction {
            println("blocking")
            previousDir = currentDir
            currentDir = .None
            self.physicsBody?.dynamic = false
        }
    }

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
        println("left: \(blocked.left), right: \(blocked.right), up: \(blocked.up), down: \(blocked.down)")

        if requestedDir == direction {
            println("unblocking")
            changeDirection(direction)
        }
    }
}
