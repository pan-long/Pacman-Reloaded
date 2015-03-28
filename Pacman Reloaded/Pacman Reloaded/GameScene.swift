//
//  GameScene.swift
//  Pacman Reloaded
//
//  Created by panlong on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // Assume there is only one pacman for now.
    let pacman = PacMan()

    // TODO Pass in the file name from map selection interface
    var TMXFileName: String? = "PacmanMapOne"
    
    override func didMoveToView(view: SKView) {
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.blackColor()

        if let fileName = TMXFileName {
            println("Loading game map from TMX file...")
            
            self.enumerateChildNodesWithName("*") {
                node, stop in
                
                node.removeFromParent()
            }
            
            parseTMXFileWithName(fileName)
        }
        
        self.anchorPoint = CGPoint(x: 0.5 - pacman.position.x / Constants.IPadWidth,
            y: 0.5 - pacman.position.y / Constants.IPadHeight)
        
        var swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        
        var swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight:")
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        var swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeUp:")
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        var swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDown:")
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
    }
    
    func swipeLeft(sender: UISwipeGestureRecognizer) {
        pacman.changeDirection(.Left)
    }

    func swipeRight(sender: UISwipeGestureRecognizer) {
        pacman.changeDirection(.Right)
    }

    func swipeUp(sender: UISwipeGestureRecognizer) {
        pacman.changeDirection(.Up)
    }
    
    func swipeDown(sender: UISwipeGestureRecognizer) {
        pacman.changeDirection(.Down)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        pacman.update()
        // Put the pacman in the center of the screen
        self.anchorPoint = CGPoint(x: 0.5 - pacman.position.x / Constants.IPadWidth,
            y: 0.5 - pacman.position.y / Constants.IPadHeight)
    }
}

extension GameScene: SKPhysicsContactDelegate {

    func didBeginContact(contact: SKPhysicsContact) {

        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch contactMask {

        case GameObjectType.PacMan | GameObjectType.PacDot :
            if let pacdot = contact.bodyA.node as? PacDot {
                pacdot.removeFromParent()
            } else if let pacdot = contact.bodyB.node as? PacDot {
                pacdot.removeFromParent()
            } else {
                println("???")
            }
            pacman.score++
            println(pacman.score)
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

    func handleSensorEvent(bodyA: SKNode?, bodyB: SKNode?, direction: Direction, start: Bool) {
        var sensor = SKNode()
        if let boundary = bodyA? as? Boundary {
            sensor = bodyB!
        } else if let boundary = bodyB? as? Boundary {
            sensor = bodyA!
        } else {
            println("???")
        }
        if let pacman = sensor.parent as? PacMan {
            if start {
                pacman.sensorContactStart(direction)
            } else {
                pacman.sensorContactEnd(direction)
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
                    
                    break
                case "pacman":
                    // TODO Support multiplayer mode
                    pacman.position = origin
                    addChild(pacman)
                    
                    break
                default:
                    break
                }
            }
        }
    }
}