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

class GameViewController: UIViewController {

    @IBOutlet weak var gameSceneView: SKView!
    
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var remainingDots: UILabel!

    var scene: GameScene?
    
    // Single player mode is the default and the play self hosts the game
    private var isHost = true
    private var isMultiplayerMode = false
    private var numberOfPlayers = 1
    
    private let newGameIdentifier = Constants.Identifiers.NewGameService
    private var connectivity: MultiplayerConnectivity = MultiplayerConnectivity(name: UIDevice.currentDevice().name)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let background = UIView()
        background.frame = self.view.frame
        background.backgroundColor = UIColor.darkGrayColor()
        view.addSubview(background)
        view.sendSubviewToBack(background)
    }

    override func viewWillAppear(animated: Bool) {
        if numberOfPlayers > 1 {
            scene?.view?.paused = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let gameLevelSelection = self.storyboard!.instantiateViewControllerWithIdentifier("gameLevelSelection") as UIViewController
        self.presentViewController(gameLevelSelection, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        connectivity.stopServiceAdvertising()
        connectivity.stopServiceBrowsing()
    }
    
    func setupGameScene(mapFile: String) {
        scene = getGameSceneFromFile()
        // Configure the view.
        let skView = gameSceneView as SKView
        skView.showsFPS = true
        skView.frameInterval = Constants.FrameInterval
        skView.showsNodeCount = true
        // skView.showsPhysics = true
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene!.scaleMode = .AspectFill
        scene!.sceneDelegate = self
        
        scene!.fileName = mapFile
    }
    
    func startGameScene(pacmanId: Int, isHost: Bool) {
        if let scene = scene as? MultiplayerGameScene {
            scene.setupPacman(pacmanId, isHost: isHost)
            connectivity.matchDelegate = self
            connectivity.stopServiceBrowsing()
            connectivity.startServiceAdvertising(Constants.Identifiers.NewGameService, discoveryInfo: [String: String]())
        }
        
        let skView = gameSceneView as SKView
        skView.presentScene(scene)
    }
    
    private func getGameSceneFromFile() -> GameScene {
        if numberOfPlayers > 1 {
            return MultiplayerGameScene.unarchiveFromFile("MultiplayerGameScene") as MultiplayerGameScene
        } else {
            return GameScene.unarchiveFromFile("GameScene") as GameScene
        }
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
        gameSceneView.scene?.view?.paused = true

    }

    func unpause() {
        self.dismissViewControllerAnimated(true, completion: {
            self.gameSceneView.scene?.view?.paused = false
            return
        })
    }

    func quit() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
    
    func countDown(timer: NSTimer) {
        if let number = pauseBtn.titleLabel?.text?.toInt() {
            if number > 0 {
                pauseBtn.setTitle(String(number - 1), forState: UIControlState.Normal)
            } else {
                pauseBtn.setTitle("Pause", forState: UIControlState.Normal)
                timer.invalidate()
                gameSceneView.scene?.view?.paused = false
                pauseBtn.enabled = true
            }
        } else {
            pauseBtn.setTitle(String(Constants.gameResumeCountDownNumber), forState: UIControlState.Normal)
            pauseBtn.enabled = false
        }
    }

    deinit {
        println("deinit Game")
    }
}

extension GameViewController: GameSceneDelegate {
    func updateScore(score: Int, dotsLeft: Int) {
        self.score.text = "Score: \(score)"
        self.remainingDots.text = "Remaining: \(dotsLeft)"
    }

    func gameDidEnd(scene: GameScene, didWin: Bool, score: Int) {
        var title: String
        if didWin {
            title = Constants.Locale.gameWin
        } else {
            title = Constants.Locale.gameOver
        }
        let alertVC = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alertVC.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: {action in
            scene.restart()
            self.gameSceneView.scene?.view?.paused = false

        }))
        gameSceneView.scene?.view?.paused = true

        self.presentViewController(alertVC, animated: true, completion: nil)

    }
}

extension GameViewController: MatchPeersDelegate {
    func browser(lostPlayer playerName: String) {}
    func browser(foundPlayer playerName: String, withDiscoveryInfo info: [NSObject : AnyObject]?) {}
    
    func didReceiveInvitationFromPlayer(playerName: String, invitationHandler: ((Bool) -> Void)) {
        var alert = UIAlertController(title: "Joining Game",
            message: "\(playerName) is asking to join your game. Allow?",
            preferredStyle: .Alert)
        
        let joinGameAction = UIAlertAction(title: "Yes", style: .Default,
            handler: { (action) -> Void in
                invitationHandler(true)
        })
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel,
            handler: { (action) -> Void in
                invitationHandler(false)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(joinGameAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func session(player playername: String, didChangeState state: MCSessionState) {
        switch state {
        case .Connected:
            let gameLevelSelection = self.storyboard!.instantiateViewControllerWithIdentifier("gameLevelSelection") as UIViewController
            self.presentViewController(gameLevelSelection, animated: true, completion: nil)
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
