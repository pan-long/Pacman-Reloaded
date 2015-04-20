//
//  NewGameRoomViewController.swift
//  Pacman Reloaded
//
//  Created by panlong on 21/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol NewGameStartDelegate: class {
    func startNewGame(sourceVC: UIViewController, hostName: String, allPlayers: [String])
    func joinNewGame(mapContent: [Dictionary<String, String>], pacmanId: Int, selfName: String, hostName: String, otherPlayersName: [String])
}

class NewGameRoomViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startBtn: UIButton!
    
    private var players = [String]()
    
    weak var gameStartDelegate: NewGameStartDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startBtnPressed(sender: AnyObject) {
        if let delegate = gameStartDelegate {
            delegate.startNewGame(self, hostName: UIDevice.currentDevice().name, allPlayers: players)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension NewGameRoomViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return self
        return players.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(Constants.Identifiers.NewGameRoomPlayerCell, forIndexPath: indexPath) as UITableViewCell
        if indexPath.row == 0 {
            cell.textLabel?.text = UIDevice.currentDevice().name
        } else {
            cell.textLabel?.text = players[indexPath.row - 1]
        }
        
        return cell
    }
}

extension NewGameRoomViewController: MatchPeersDelegate {
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
            // connected with host, enter game and set game scene
            players.append(playername)
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: players.count, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case .Connecting:
            // try connecting to the host, show an indicator with cancel button
            break
        case .NotConnected:
            // there is a problem connecting with the host, show an alert message
            if let index = find(players, playername) {
                players.removeAtIndex(index)
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index + 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            break
        default:
            break
        }
    }
    
    func browser(foundPlayer playerName: String, withDiscoveryInfo info: [NSObject : AnyObject]?) {
    }
    
    func browser(lostPlayer playerName: String) {
    }
}

extension NewGameRoomViewController: SessionDataDelegate {
    // Received data from remote player
    func session(didReceiveData data: NSData, fromPlayer playerName: String) {
        let unarchivedData: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        println("recieved data")
        if let gameInitData = unarchivedData as? GameNetworkInitData {
            if let delegate = gameStartDelegate {
                delegate.joinNewGame(gameInitData.mapContent, pacmanId: gameInitData.pacmanId, selfName: UIDevice.currentDevice().name, hostName: gameInitData.hostName, otherPlayersName: gameInitData.allPlayersName)
            }
        }
    }
}