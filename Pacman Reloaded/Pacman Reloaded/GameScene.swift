//
//  GameScene.swift
//  Pacman Reloaded
//
//  Created by panlong on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit
import AVFoundation

protocol MovementDataSource {
    func getVisibleObjects() -> [MovableObject]
}


class GameScene: SKScene {

    weak var sceneDelegate: GameSceneDelegate!
    
    // Initiate game objects
    var pacman = PacMan()
    var blinky = Ghost(imageName: "ghost-red")
    var pinky = Ghost(imageName: "ghost-yellow")
    var inky = Ghost(imageName: "ghost-blue")
    var clyde = Ghost(imageName: "ghost-orange")
    var totalPacDots:Int = 0
    
    var pacmanMovement: GestureMovementControl!
    var blinkyMovement: MovementControl!
    var pinkyMovement: MovementControl!
    var inkyMovement: MovementControl!
    var clydeMovement: MovementControl!
    
    
    var ghosts: [Ghost]!
    var ghostMovements: [MovementControl]!
    
    
    // TODO Pass in the file name from map selection interface
    var TMXFileName: String? = "PacmanMapOne"
    
    override func didMoveToView(view: SKView) {
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.blackColor()

        setupGameObjects()
        
        ghosts = [blinky, pinky, inky, clyde]
        
        // Set up movemnt control
        pacmanMovement = GestureMovementControl(movableObject: pacman)
        pacmanMovement.dataSource = self
        
        blinkyMovement = BlinkyAIMovememntControl(movableObject: blinky)
        pinkyMovement = PinkyAIMovementControl(movableObject: pinky)
        inkyMovement = InkyAIMovememntControl(movableObject: inky)
        clydeMovement = ClydeAIMovememntControl(movableObject: clyde)
        
        ghostMovements = [blinkyMovement, pinkyMovement, inkyMovement, clydeMovement]
        for i in 0..<ghostMovements.count {
            ghostMovements[i].dataSource = self
        }
        
        self.anchorPoint = CGPoint(x: 0.5 - pacman.position.x / Constants.IPadWidth,
            y: 0.5 - pacman.position.y / Constants.IPadHeight)
        
        var swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: pacmanMovement, action: "swipeLeft:")
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        
        var swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: pacmanMovement, action: "swipeRight:")
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        var swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: pacmanMovement, action: "swipeUp:")
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        var swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: pacmanMovement, action: "swipeDown:")
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
    }

    func setupGameObjects() {
        if let fileName = TMXFileName {
            println("Loading game map from TMX file...")

            self.enumerateChildNodesWithName("*") {
                node, stop in
                node.removeFromParent()
            }

            parseTMXFileWithName(fileName)
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        // Update directions of sprite nodes
        for ghostMovement in ghostMovements {
            ghostMovement.update()
        }
        
        // Update positions of sprite nodes
        pacman.update()
        for ghost in ghosts {
            ghost.update()
        }
        // Put the pacman in the center of the screen
        self.anchorPoint = CGPoint(x: 0.5 - pacman.position.x / Constants.IPadWidth,
            y: 0.5 - pacman.position.y / Constants.IPadHeight)
    }

    deinit {
        println("deinit Scene")
    }
}

extension GameScene: MovementDataSource {
    func getVisibleObjects() -> [MovableObject] {
        var visibleObjects = [MovableObject]()
        visibleObjects.append(pacman)
        return visibleObjects
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
            
        case GameObjectType.PacMan | GameObjectType.PacDot:
            if let pacdot = contact.bodyA.node as? PacDot {
                handlePacDotEvent(pacdot, pacman: contact.bodyB.node as PacMan)
            } else if let pacdot = contact.bodyB.node as? PacDot {
                handlePacDotEvent(pacdot, pacman: contact.bodyA.node as PacMan)
            }
        case GameObjectType.PacMan | GameObjectType.Ghost:
            gameOver(false)
        case GameObjectType.Boundary | GameObjectType.SensorUp:
            handleSensorEvent(contact.bodyA.node, bodyB: contact.bodyB.node, direction: .Up, start: true)
        case GameObjectType.Boundary | GameObjectType.SensorDown:
            handleSensorEvent(contact.bodyA.node, bodyB: contact.bodyB.node, direction: .Down, start: true)
        case GameObjectType.Boundary | GameObjectType.SensorLeft:
            handleSensorEvent(contact.bodyA.node, bodyB: contact.bodyB.node, direction: .Left, start: true)
        case GameObjectType.Boundary | GameObjectType.SensorRight:
            handleSensorEvent(contact.bodyA.node, bodyB: contact.bodyB.node, direction: .Right, start: true)
        default:
            return
        }
    }

    func gameOver(didWin: Bool) {
        self.sceneDelegate.gameDidEnd(self, didWin: didWin, score: pacman.score)
    }

    func restart() {
        pacman.reset()
        blinky.reset()

        setupGameObjects()
        sceneDelegate.updateScore(pacman.score, dotsLeft: totalPacDots)

        println("START")
    }

    func handlePacDotEvent(pacdot: PacDot, pacman: PacMan) {
        pacdot.removeFromParent()
        pacman.score++
        totalPacDots--
        if pacdot.isSuper {
            println("super")
        }
        sceneDelegate.updateScore(pacman.score, dotsLeft: totalPacDots)
        if totalPacDots == 0 {
            self.sceneDelegate.gameDidEnd(self, didWin: true, score: pacman.score)
        }
        //self.runAction(AudioManager.pacdotSoundEffectAction())
    }
    
    func handleSensorEvent(bodyA: SKNode?, bodyB: SKNode?, direction: Direction, start: Bool) {
        var sensor = SKNode()
        if let boundary = bodyA? as? Boundary {
            if let bodyB = bodyB {
                sensor = bodyB
            } else {
                return // early termination, sensor is aready destroyed
            }
        } else if let boundary = bodyB? as? Boundary {
            if let bodyA = bodyA {
                sensor = bodyA
            } else {
                return // early termination, sensor is aready destroyed
            }
        } else {
            println("???")
        }
        if let owner = sensor.parent as? MovableObject {
            if start {
                owner.sensorContactStart(direction)
            } else {
                owner.sensorContactEnd(direction)
            }
        }
    }
    
    
    
    func didEndContact(contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
            
        case GameObjectType.Boundary | GameObjectType.SensorUp:
            handleSensorEvent(contact.bodyA.node, bodyB: contact.bodyB.node, direction: .Up, start: false)
        case GameObjectType.Boundary | GameObjectType.SensorDown:
            handleSensorEvent(contact.bodyA.node, bodyB: contact.bodyB.node, direction: .Down, start: false)
        case GameObjectType.Boundary | GameObjectType.SensorLeft:
            handleSensorEvent(contact.bodyA.node, bodyB: contact.bodyB.node, direction: .Left, start: false)
        case GameObjectType.Boundary | GameObjectType.SensorRight:
            handleSensorEvent(contact.bodyA.node, bodyB: contact.bodyB.node, direction: .Right, start: false)
        default:
            return
            
        }
        
    }
}

extension GameScene: NSXMLParserDelegate {
    func parseTMXFileWithName(name: String) {
        let path: String = NSBundle.mainBundle().pathForResource(name, ofType: "tmx")!
        let data: NSData = NSData(contentsOfFile: path)!
        let parser: NSXMLParser = NSXMLParser(data: data)
        
        parser.delegate = self
        self.totalPacDots = 0
        parser.parse()
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {

        if elementName == "object" {
            let type: AnyObject? = attributeDict["type"]
            
            if let typeStr = type as? String {
                let width = CGFloat((attributeDict["width"] as String).toInt()!)
                let height = CGFloat((attributeDict["height"] as String).toInt()!)
                let size = CGSize(width: width, height: height)
                
                let xPos = CGFloat((attributeDict["x"] as String).toInt()!) + width/2
                let yPos = Constants.IPadHeight - CGFloat((attributeDict["y"] as String).toInt()!)
                    - height/2
                let origin = CGPoint(x: xPos, y: yPos)
                
                switch typeStr {
                case "boundary":
                    let boundary = Boundary(size: size, isExterior: false)
                    addChild(boundary)
                    boundary.position = origin
                    
                    break
                case "edge":
                    let boundary = Boundary(size: size, isExterior: true)
                    addChild(boundary)
                    boundary.position = origin
                    
                    break
                case "pacdot":
                    let pacdot = PacDot(size: size)
                    addChild(pacdot)
                    pacdot.position = origin
                    self.totalPacDots++
                    break
                case "super-pacdot":
                    let pacdot = PacDot(superSize: size)
                    addChild(pacdot)
                    pacdot.position = origin
                    self.totalPacDots++
                    break
                case "pacman":
                    // TODO Support multiplayer mode
                    pacman.position = origin
                    addChild(pacman)
                    
                    break
                case "blinky":
                    blinky.position = origin
                    addChild(blinky)
                    println("set up blinky")
                    
                    break
                case "pinky":
                    pinky.position = origin
                    addChild(pinky)
                    println("set up pinky")
                    
                    break
                case "inky":
                    inky.position = origin
                    addChild(inky)
                    println("set up inky")
                    
                    break
                case "clyde":
                    clyde.position = origin
                    addChild(clyde)
                    println("set up clyde")
                    
                    break
                default:
                    break
                }
            }
        }
    }
}
