//
//  MultiplayerManagementViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

class MultiplayerManagementViewController: UIViewController {
    
    @IBOutlet weak var newGameTable: UITableView!
    
    private let newGameIdentifier = Constants.Identifiers.NewGameService
    private var newGames: [String] = []
    private var gameIndices = Dictionary<String, Int>()
    private var connectivity = MultiplayerConnectivity(name: UIDevice.currentDevice().name) // Current iPad name
    
    private var isHost = false
    private var pacmanId = 0
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.blackColor()
        newGameTable.layer.cornerRadius = CGFloat(19) // TODO Magic number
        newGameTable.delegate = self
        newGameTable.dataSource = self
        connectivity.matchDelegate = self
        connectivity.startServiceBrowsing(newGameIdentifier)
    }
    
    deinit {
        println("multi management deinited")
    }
    
    @IBAction func createNewGame(sender: AnyObject) {
        isHost = true
        pacmanId = 0
        performSegueWithIdentifier(Constants.Identifiers.MultiplayerGameSegueIdentifier, sender: self)
    }
    
    @IBAction func BackToHome(sender: AnyObject) {
        newGameTable.delegate = nil
        newGameTable.dataSource = nil
        connectivity.matchDelegate = nil
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MultiplayerManagementViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Alert to confirm joining game
        var alert = UIAlertController(title: "Joining Game",
            message: "Are you sure to join \(newGames[indexPath.row])?",
            preferredStyle: .Alert)

        // If confirmed, send invitation
        let joinGameAction = UIAlertAction(title: "Yes", style: .Default,
            handler: { (action) -> Void in
                self.connectivity.sendInvitation(toPlayer: self.newGames[indexPath.row])
        })
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel,handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(joinGameAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCellIdentifier = Constants.Identifiers.NewGameTableCell
        var cell = tableView.dequeueReusableCellWithIdentifier(tableCellIdentifier) as UITableViewCell
        cell.textLabel!.text = newGames[indexPath.row]
        return cell
    }
}

extension MultiplayerManagementViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newGames.count
    }
}

extension MultiplayerManagementViewController: MatchPeersDelegate {
    func didReceiveInvitationFromPlayer(playerName: String, invitationHandler: ((Bool) -> Void)) {}
    func session(player playername: String, didChangeState state: MCSessionState) {
        switch state {
        case .Connected:
            // connected with host, enter game and set game scene
            performSegueWithIdentifier(Constants.Identifiers.MultiplayerGameSegueIdentifier, sender: nil)
            break
        case .Connecting:
            // try connecting to the host, show an indicator with cancel button
            break
        case .NotConnected:
            // there is a problem connecting with the host, show an alert message
            break
        default:
            break
        }
    }
    
    func browser(foundPlayer playerName: String, withDiscoveryInfo info: [NSObject : AnyObject]?) {
        newGames.append(playerName)
        gameIndices[playerName] = newGames.count - 1
        newGameTable.reloadData()
    }
    
    func browser(lostPlayer playerName: String) {
        if let index = gameIndices[playerName] {
            newGames.removeAtIndex(index)
            gameIndices.removeValueForKey(playerName)
            newGameTable.reloadData()
        }
    }
}