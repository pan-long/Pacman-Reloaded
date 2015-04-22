//
//  GameScene.swift
//  Pacman Reloaded
//
//  Created by panlong on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit
import AVFoundation


class GameScene: SKScene {

    weak var sceneDelegate: GameSceneDelegate!
    weak var presentingView: SKView!

    // Initiate game objects, for single player mode, just set the id of pacman as 0, a dummy value
    var pacman = PacMan(id: 0)
    
    var blinkys = [Ghost]()
    var pinkys = [Ghost]()
    var inkys = [Ghost]()
    var clydes = [Ghost]()

    var totalPacDots:Int = 0
    var spotLightTimer: NSTimer?
    
    var spotLightView: SpotLightUIView!

    var pacmanMovement: GestureMovementControl!

    var swipeLeft: UISwipeGestureRecognizer!

    var swipeRight: UISwipeGestureRecognizer!

    var swipeUp: UISwipeGestureRecognizer!

    var swipeDown: UISwipeGestureRecognizer!

    var ghosts: [Ghost]!
    var ghostMovements: [MovementControl]!

    var superDotEvents: [() -> Void] = []
    
    var mapContent: [Dictionary<String, String>]?

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.clearColor()
        self.presentingView = view
        view.allowsTransparency = true
        
        // set up the lightspot view for blind special effects
        setupLightView(inParentView: view)
       
        initGameScene()
        setPacmanAtCenter()
    }
    
    func setup(fromMapContent content: [Dictionary<String, String>]) {
        // set up game physics world
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        mapContent = content
    }
    
    private func initGameScene() {
        initGameObjects()
        setupGameObjects()
        setupMisc()
        setupMovementControls()
    }
    
    private func setPacmanAtCenter() {
        // keep the pacman to be at the center of the game scene
        self.anchorPoint = CGPoint(x: 0.5 - pacman.position.x / CGFloat(Constants.GameScene.Width),
            y: 0.5 - pacman.position.y / CGFloat(Constants.GameScene.Height))
    }
    
    private func setupLightView(inParentView view: SKView) {
        let spotLightViewFrame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        spotLightView = SpotLightUIView(
            spotLightCenter: getGameSceneCenter(),
            frame: spotLightViewFrame)
    }
    
    private func getGameSceneCenter() -> CGPoint {
        return CGPoint(
            x: 0.5 + view!.bounds.size.width / 2,
            y: 0.5 + view!.bounds.size.height / 2)
    }
    
    private func setupMovementControls() {
        setupOwnPacmanGestureMovementControl()
        setupObjectsMovementControl()
        setGhostMovementDatasource()
    }
    
    func initGameObjects() {
        pacman = PacMan(id: 0)
        
        blinkys = [Ghost]()
        pinkys = [Ghost]()
        inkys = [Ghost]()
        clydes = [Ghost]()
        
        ghostMovements = [MovementControl]()
        totalPacDots = 0
    }
    
    private func setupOwnPacmanGestureMovementControl() {
        // Only use gestures to control your own pacman
        
        // Set up movemnt control
        pacmanMovement = GestureMovementControl(movableObject: pacman)
        pacmanMovement.dataSource = self
        
        // setup gesture recognizer
        swipeLeft = UISwipeGestureRecognizer(target: pacmanMovement, action: "swipeLeft:")
        swipeLeft.direction = .Left
        self.presentingView.addGestureRecognizer(swipeLeft)
        
        swipeRight = UISwipeGestureRecognizer(target: pacmanMovement, action: "swipeRight:")
        swipeRight.direction = .Right
        self.presentingView.addGestureRecognizer(swipeRight)
        
        swipeUp = UISwipeGestureRecognizer(target: pacmanMovement, action: "swipeUp:")
        swipeUp.direction = .Up
        self.presentingView.addGestureRecognizer(swipeUp)
        
        swipeDown = UISwipeGestureRecognizer(target: pacmanMovement, action: "swipeDown:")
        swipeDown.direction = .Down
        self.presentingView.addGestureRecognizer(swipeDown)
    }
    
    func setupObjectsMovementControl() {
        // Use AI to control ghosts
        for blinky in blinkys {
            var blinkyMovement = BlinkyAIMovememntControl(movableObject: blinky)
            ghostMovements.append(blinkyMovement)
        }
        
        for pinky in pinkys {
            var pinkyMovement = PinkyAIMovementControl(movableObject: pinky)
            ghostMovements.append(pinkyMovement)
        }
        
        for inky in inkys {
            var inkyMovement = InkyAIMovementControl(movableObject: inky)
            ghostMovements.append(inkyMovement)
        }
        
        for clyde in clydes {
            var clydeMovement = ClydeAIMovementControl(movableObject: clyde)
            ghostMovements.append(clydeMovement)
        }
    }
    
    private func setGhostMovementDatasource() {
        for i in 0..<ghostMovements.count {
            ghostMovements[i].dataSource = self
        }
    }
    
    private func setupMisc() {
        // every super dot has special effect, listed as different events
        self.superDotEvents = [
            { [weak self] () -> Void in
                self?.frightenGhost()
                return
            },
            { [weak self] () -> Void in
                self?.spotLightMode()
                return
            },
            { [weak self] () -> Void in
                self?.earnExtraPoints()
                return
            }
        ]
    }
    
    func setupGameObjects() {
        // clear map
        clearMap()
        
        // read from map data
        if let map = mapContent {
            parseMapWithData(map)

        }
        
        sceneDelegate.updateScore(pacman.score, dotsLeft: totalPacDots)
        // for convenience, combine all ghosts in one array
        ghosts = blinkys + pinkys + inkys + clydes
    }
    
    private func clearMap() {
        self.enumerateChildNodesWithName("*") {
            node, stop in
            node.removeFromParent()
        }
    }
    
    func gameOver(didWin: Bool) {
        self.sceneDelegate.gameDidEnd(self, didWin: didWin, score: pacman.score)
    }
    
    func restart() {
        // stop spotlight effect on game scene
        stopSpotLight()
        
        initGameScene()
        
        sceneDelegate.updateScore(pacman.score, dotsLeft: totalPacDots)
        sceneDelegate.iniatilizeMovableObjectPosition()
        
        println("START")
    }
    
    private func stopSpotLight() {
        sceneDelegate?.stopLightView()
        if spotLightTimer != nil {
            self.spotLightTimer!.invalidate()
            self.spotLightTimer = nil
            spotLightView.removeFromSuperview()
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
        
        // Keep pacman at the center of the screen
        setPacmanAtCenter()
        // Update positions of movable objects in mini game scene as well
        sceneDelegate.updateMovableObjectPosition()
    }
    
    deinit {
        // debug use, check if game scene is released on exiting
        println("deinit Scene")
    }
}

extension GameScene: MovementDataSource {
    func getPacmans() -> [MovableObject] {
        var pacmans = [MovableObject]()
        pacmans.append(pacman)
        return pacmans
    }
    
    func getBlinkys() -> [MovableObject] {
        return blinkys
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
            handleGhostPacmanEvent(contact.bodyA.node, bodyB: contact.bodyB.node)
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
    
    private func handleGhostPacmanEvent(bodyA: SKNode?, bodyB: SKNode?) {
        var pacman: PacMan!
        var ghost: Ghost!
        if let bodyA = bodyA? as? PacMan {
            if let bodyB = bodyB? as? Ghost  {
                pacman = bodyA
                ghost = bodyB
            }
        } else if let bodyB = bodyB? as? PacMan {
            if let bodyA = bodyA? as? Ghost {
                pacman = bodyB
                ghost = bodyA
            }
        } else {
            println("???")
            return //
        }
        
        if !ghost.frightened {
            gameOver(false)
        } else if !ghost.eaten {
            pacman.score += Constants.Score.Ghost
            ghost.eaten = true
            sceneDelegate.updateScore(pacman.score, dotsLeft: totalPacDots)
        }
    }
    
    private func handlePacDotEvent(pacdot: PacDot, pacman: PacMan) {
        pacdot.removeFromParent()
        pacman.score += Constants.Score.PacDot
        totalPacDots--
        if pacdot.isSuper {
            let roll = Int(arc4random_uniform(UInt32(self.superDotEvents.count)))
            self.superDotEvents[roll]()
        }
        sceneDelegate.updateScore(pacman.score, dotsLeft: totalPacDots)
        if totalPacDots == 0 {
            self.sceneDelegate.gameDidEnd(self, didWin: true, score: pacman.score)
        }
        self.runAction(AudioManager.pacdotSoundEffectAction())
    }
    
    private func displayExtraPoint(point: Int) {
        let gameSceneCenter = getGameSceneCenter()
        let pointViewX = gameSceneCenter.x - pacman.sprite.size.width / 2
        let pointViewY = gameSceneCenter.y - pacman.sprite.size.height * 3/2
        let pointView = UILabel(frame:
            CGRectMake(pointViewX, pointViewY, pacman.sprite.size.width, pacman.sprite.size.height))
        pointView.backgroundColor = UIColor.clearColor()
        pointView.textColor = UIColor.whiteColor()
        pointView.text = String(point)

        self.view!.addSubview(pointView)
        UIView.animateWithDuration(Constants.GameScene.ExtraPointDuration,
            delay: NSTimeInterval(0),
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                pointView.alpha = 0
            }, completion: {complete in
                pointView.removeFromSuperview()})
    }
    
    private func earnExtraPoints() {
        displayExtraPoint(Constants.Score.ExtraPointDot)
        pacman.score += Constants.Score.ExtraPointDot
        sceneDelegate.updateScore(pacman.score, dotsLeft: totalPacDots)
    }
    
    private func spotLightMode() {
        if spotLightTimer != nil {
            // if there is an existing spotlight effect, stop that first
            stopSpotLight()
        }
        view!.addSubview(spotLightView)
        
        self.spotLightTimer = NSTimer.scheduledTimerWithTimeInterval(
            Constants.GameScene.SpotLightDuration,
            target: self,
            selector: "endSpotLightMode:",
            userInfo: nil,
            repeats: false)
        sceneDelegate.startLightView()
    }
    
    func endSpotLightMode(timer: NSTimer) {
        spotLightView.removeFromSuperview()
        
        // release the resources
        stopSpotLight()
    }
    
    private func frightenGhost() {
        for ghost in ghosts {
            ghost.frightened = true
            let wait = SKAction.waitForDuration(Constants.Ghost.FrightenModeDuration)
            let blinkOnce = SKAction.sequence([
                SKAction.fadeOutWithDuration(Constants.Ghost.FrightenModeBlinkDuration),
                SKAction.fadeInWithDuration(Constants.Ghost.FrightenModeBlinkDuration)
                ])
            let blink = SKAction.repeatAction(blinkOnce, count: Constants.Ghost.FrightenModeBlinkCount)
            
            let resetFrighten = SKAction.runBlock {
                ghost.frightened = false
            }
            
            ghost.runAction(SKAction.sequence([wait, blink, resetFrighten]), withKey: "frighten")
        }
        
    }
    
    private func handleSensorEvent(bodyA: SKNode?, bodyB: SKNode?, direction: Direction, start: Bool) {
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

extension GameScene {
    private func parseMapWithData(content: [Dictionary<String, String>]) {
        self.totalPacDots = 0
        
        for i in 0..<content.count {
            let gameObject = content[i]
            let type = gameObject["type"]!
            let width = CGFloat(gameObject["width"]!.toInt()!)
            let height = CGFloat(gameObject["height"]!.toInt()!)
            var size = CGSize(width: width, height: height)
            
            let xPos = CGFloat(gameObject["x"]!.toInt()!)
            let yPos = CGFloat(gameObject["y"]!.toInt()!)
            let origin = CGPoint(x: xPos, y: yPos)
            
            switch type {
            case "boundary":
                size = CGSize(width: 40, height: 40)
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
                let pacdot = PacDot(id: i, size: size)
                addChild(pacdot)
                pacdot.position = origin
                self.totalPacDots++
                break
            case "super-pacdot":
                let pacdot = PacDot(id: i, superSize: size)
                addChild(pacdot)
                pacdot.position = origin
                self.totalPacDots++
                break
            case "pacman":
                addPacmanFromMapData(i, position: adjustOriginForMovableObject(origin))
                
                break
            case "blinky":
                var blinky = Ghost(id: i, imageName: "ghost-red")
                blinky.position = adjustOriginForMovableObject(origin)
                addChild(blinky)
                blinkys.append(blinky)
                
                break
            case "pinky":
                var pinky = Ghost(id: i, imageName: "ghost-yellow")
                pinky.position = adjustOriginForMovableObject(origin)
                addChild(pinky)
                pinkys.append(pinky)
                
                break
            case "inky":
                var inky = Ghost(id: i, imageName: "ghost-blue")
                inky.position = adjustOriginForMovableObject(origin)
                addChild(inky)
                inkys.append(inky)
                break
            case "clyde":
                var clyde = Ghost(id: i, imageName: "ghost-orange")
                clyde.position = adjustOriginForMovableObject(origin)
                addChild(clyde)
                clydes.append(clyde)
                
                break
            default:
                break
            }
        }
    }
    
    func addPacmanFromMapData(id: Int, position: CGPoint) {
        pacman.position = position
        removeChildrenInArray([pacman])
        addChild(pacman)
    }

    private func adjustOriginForMovableObject(origin: CGPoint) -> CGPoint {
        return CGPoint(x: origin.x - Constants.GameScene.MovableObjectAdjustment, y: origin.y)
    }
}

extension GameScene {
    // Return an array of movable objects currently in the game scene
    func getMovableObjects() -> [MovableObject] {
        var res: [MovableObject] = []
        res.append(pacman)
        res = res + ghosts
        return res
    }
    
    // Return mappings of movable objects with their positions
    func getMovableObjectsWithPosition() -> Dictionary<MovableObject, CGPoint> {
        let movableObjects = getMovableObjects()
        var res = Dictionary<MovableObject, CGPoint>()
        for movableObj in movableObjects {
            res[movableObj] = movableObj.position
        }
        return res
    }
}
