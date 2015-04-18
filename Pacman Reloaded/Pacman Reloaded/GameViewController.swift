//
//  GameViewController.swift
//  Pacman Reloaded
//
//  Created by panlong on 17/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
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

    override func viewDidLoad() {
        super.viewDidLoad()

        let background = UIView()
        background.frame = self.view.frame
        background.backgroundColor = UIColor.darkGrayColor()
        view.addSubview(background)
        view.sendSubviewToBack(background)


        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = gameSceneView as SKView
            skView.showsFPS = true
            skView.frameInterval = Constants.FrameInterval
            skView.showsNodeCount = true
            // skView.showsPhysics = true
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.sceneDelegate = self
            skView.presentScene(scene)
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
