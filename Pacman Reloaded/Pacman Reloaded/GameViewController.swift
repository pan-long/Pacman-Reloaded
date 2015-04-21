//
//  GameViewController.swift
//  Pacman Reloaded
//
//  Created by panlong on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit
import SpriteKit
import MultipeerConnectivity

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as SKNode
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: GameBackgroundViewController, GameEndDelegate {

    @IBOutlet weak var gameSceneView: SKView!
    
    @IBOutlet weak var score: UICountingLabel!
    @IBOutlet weak var remainingDots: UILabel!
    @IBOutlet weak var miniMap: UIImageView!
    
    var scene: GameScene?
    
    // Single player mode is the default and the play self hosts the game
    private var pacmanId = 0
    private var isMultiplayerMode = false
    private var isHost = true
    
    private var numberOfPlayers = 1
    
    private var mapData: [Dictionary<String, String>]!
    
    private let newGameIdentifier = Constants.Identifiers.NewGameService
    private var gameCenter: GameCenter?
    
    private var miniMapMovableObjects = Dictionary<MovableObject, UIImageView>()
    private var miniMapImage: UIImage?
    private var miniMapLightView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameSceneView.backgroundColor = UIColor.clearColor()
        gameSceneView.alpha = Constants.GameScene.GameSceneViewAlphaStart
    }

    func setupSingleGame(fromMap mapData: [Dictionary<String, String>], miniMapImage: UIImage) {
        setupGameProperties(fromMap: mapData, pacmanId: 0, isMultiplayerMode: false, isHost: true, miniMapImage: miniMapImage)
        
        setupGameScene()
        addGameSceneToView()
        setupMiniMap()
    }
    
    func setupMultiplayerGame(fromMap mapData: [Dictionary<String, String>], pacmanId: Int, isHost: Bool, gameCenter: GameCenter, miniMapImage: UIImage) {
        setupGameProperties(fromMap: mapData, pacmanId: pacmanId, isMultiplayerMode: true, isHost: isHost, miniMapImage: miniMapImage)
        
        self.gameCenter = gameCenter
        
        println("pacman id: \(pacmanId)")
    }
    
    private func setupGameProperties(fromMap mapData: [Dictionary<String, String>], pacmanId: Int, isMultiplayerMode: Bool, isHost: Bool, miniMapImage: UIImage) {
        self.mapData = mapData
        self.pacmanId = pacmanId
        self.isMultiplayerMode = isMultiplayerMode
        self.isHost = isHost
        self.miniMapImage = miniMapImage
    }
    
    override func viewWillAppear(animated: Bool) {
        if isMultiplayerMode {
            setupGameScene()
            addGameSceneToView()
            setupMiniMap()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if !isMultiplayerMode { // in single player mode, pop up the level selection window
            var gameLevelSelection = self.storyboard!.instantiateViewControllerWithIdentifier("gameLevelSelection") as GameLevelLoadingViewController
            gameLevelSelection.delegate = self
            self.presentViewController(gameLevelSelection, animated: true, completion: nil)
        }
    }
    
    private func setupGameScene() {
        // initialize game scene from spritkit resource file
        scene = getGameSceneFromFile()
        gameSceneView.alpha = Constants.GameScene.GameSceneViewAlphaEnd
        
        setupGameSKView()
        
        /* Set the scale mode to scale to fit the window */
        scene!.scaleMode = .AspectFill
        scene!.sceneDelegate = self
        
        if let scene = scene as? MultiplayerGameScene {
            scene.setupPacman(fromMapContent: mapData, pacmanId: pacmanId, isHost: isHost)
            scene.networkDelegate = gameCenter
        } else {
            scene!.setup(fromMapContent: mapData)
        }
    }
    
    private func setupGameSKView() {
        // Configure the view.
        let skView = gameSceneView as SKView
        skView.showsFPS = true
        skView.frameInterval = Constants.FrameInterval
        skView.showsNodeCount = true
        // skView.showsPhysics = true
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
    }
    
    private func addGameSceneToView() {
        let skView = gameSceneView as SKView
        skView.presentScene(scene)
    }
    
    private func getGameSceneFromFile() -> GameScene {
        var resultScene: GameScene!
        if isMultiplayerMode {
            resultScene = MultiplayerGameScene.unarchiveFromFile("MultiplayerGameScene") as MultiplayerGameScene
        } else {
            resultScene = GameScene.unarchiveFromFile("GameScene") as GameScene
        }
        
        resultScene.size = CGSize(width: Constants.GameScene.Width,
            height: Constants.GameScene.Height)
        return resultScene
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // pause the game first whenever navigating to other vc
        gameSceneView.scene?.view?.paused = true
    }

    func resume() {
        self.dismissViewControllerAnimated(true, completion: {
            self.gameSceneView.scene?.view?.paused = false
            return
        })
    }
    
    func restart() {
        self.scene!.restart()
        
        resume()
    }

    // pause button action
    @IBAction private func pauseBtnClicked(button: UIButton) {
        button.enabled = false
        gameSceneView.scene?.view?.paused = true
        
        // present an popup view for user to change some settings
        let alertVC = UIAlertController(title: "Game Paused", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alertVC.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: {action in
            let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countDown:", userInfo: nil, repeats: true)
            ()
        }))

        self.presentViewController(alertVC, animated: true, completion: nil)
    }

    deinit {
        println("deinit Game")
    }
}

extension GameViewController: GameSceneDelegate {
    func updateScore(score: Int, dotsLeft: Int) {
        self.score.updateTo(score)
        self.remainingDots.text = "Remaining: \(dotsLeft)"
    }

    func gameDidEnd(scene: GameScene, didWin: Bool, score: Int) {
        var title: String
        if didWin {
            title = Constants.Locale.GameWin
        } else {
            title = Constants.Locale.GameOver
        }
        gameSceneView.scene?.view?.paused = true
        
        var gameEnd = self.storyboard!.instantiateViewControllerWithIdentifier("gameEnd") as GameEndViewController
        gameEnd.delegate = self
        gameEnd.viewTitle = title
        gameEnd.score = score
        self.presentViewController(gameEnd, animated: true, completion: nil)

    }
    
    func iniatilizeMovableObjectPosition() {
        initializeMiniMap()
    }
    
    func updateMovableObjectPosition() {
        updateMiniMap()
    }
    
    func startLightView() {
        if miniMapLightView == nil {
            miniMapLightView = UIView()
            miniMapLightView.frame.origin = miniMap.frame.origin
            miniMapLightView.frame.size = miniMap.frame.size
            miniMapLightView.backgroundColor = UIColor.blackColor()
            view.addSubview(miniMapLightView)
        }
        miniMapLightView.hidden = false
    }
    
    func stopLightView() {
        miniMapLightView.hidden = true
    }
}

// MARK: - GameLevelLoadingDelegate
extension GameViewController: GameLevelLoadingDelegate {
    func willCancel(sourceVC: UIViewController) {

    }

    func didSelectedLevel(sourceVC: UIViewController, mapContent: [Dictionary<String, String>], miniMapImage: UIImage) {
        setupSingleGame(fromMap: mapContent, miniMapImage: miniMapImage)
        sourceVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func session(player playername: String, didChangeState state: MCSessionState) {
        switch state {
        case .Connected:
//            let gameLevelSelection = self.storyboard!.instantiateViewControllerWithIdentifier("gameLevelSelection") as UIViewController
//            self.presentViewController(gameLevelSelection, animated: true, completion: nil)
            println("connected")
            break
        case .Connecting:
            println("connecting")
            break
        case .NotConnected:
            // Player disconnected from game
            println("not connected")
            break
        default:
            break
        }
    }
}

// MARK: - MiniMap
extension GameViewController {
    
    private func gameScenePosToMiniMapPos(position: CGPoint) -> CGPoint {
        let xRatio = position.x / CGFloat(Constants.GameScene.TotalWidth)
        let yRatio = (CGFloat(Constants.GameScene.Height) - position.y) /
            CGFloat(Constants.GameScene.TotalHeight)
        
        return CGPoint(x: xRatio * CGFloat(Constants.GameScene.MiniMapWidth),
            y: yRatio * CGFloat(Constants.GameScene.MiniMapHeight))
    }
    
    func setupMiniMap() {
        if let miniMapImage = miniMapImage {
            miniMap.image = miniMapImage
            miniMap.alpha = 0.5
            initializeMiniMap()
            updateMiniMap()
        }
    }
    
    func initializeMiniMap() {
        for subview in miniMap.subviews {
            subview.removeFromSuperview()
        }
        
        miniMapMovableObjects = Dictionary<MovableObject, UIImageView>()
        let movableObjs = scene!.getMovableObjectsWithPosition()
        for obj in movableObjs.keys {
            let image = UIImage(named: obj.image)
            let imageView = UIImageView(image: image)
            imageView.frame.size = CGSize(width: Constants.GameScene.MiniGridWidth,
                height: Constants.GameScene.MiniGridHeight)
            miniMap.addSubview(imageView)
            miniMap.bringSubviewToFront(imageView)
            miniMapMovableObjects[obj] = imageView
        }
    }
    
    func updateMiniMap() {
        let movableObjs = scene!.getMovableObjectsWithPosition()
        for obj in movableObjs.keys {
            if let imageView = miniMapMovableObjects[obj] {
                imageView.center = gameScenePosToMiniMapPos(movableObjs[obj]!)
            }
        }
    }
}