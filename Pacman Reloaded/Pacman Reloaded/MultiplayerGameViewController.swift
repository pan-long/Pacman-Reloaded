//
//  MultiplayerGameViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

class MultiplayerGameViewController: UIViewController {
    
    @IBOutlet var gameSceneView: SKView!
    private var numberOfPlayers = 1
    
    private let newGameIdentifier = Constants.Identifiers.NewGame
    private var connectivity = MultiplayerConnectivity(name: UIDevice.currentDevice().name)
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Present game settings
        let gameSetting = self.storyboard!.instantiateViewControllerWithIdentifier("gameSetting") as UIViewController
        self.presentViewController(gameSetting, animated: true, completion: nil)
    }
    
    func setNumberOfPlayers(numberOfPlayers: Int) {
        self.numberOfPlayers = numberOfPlayers
        
        self.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.connectivity.matchDelegate = self
            self.connectivity.startServiceAdvertising(self.newGameIdentifier,
                discoveryInfo: Dictionary<String, String>())
            self.connectivity.stopServiceBrowsing()
        })
    }
}

extension MultiplayerGameViewController: MatchPeersDelegate {
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