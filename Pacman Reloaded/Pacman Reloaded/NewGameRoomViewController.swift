//
//  NewGameRoomViewController.swift
//  Pacman Reloaded
//
//  Created by panlong on 21/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol GameRoomDelegate: class {
    func startNewGame(sourceVC: UIViewController, allPlayers: [String])
    func joinNewGame(sourceVC: UIViewController, pacmanId: Int, mapContent: [Dictionary<String, String>], miniMapImage: UIImage)
    func quitGameRoom(sourceVC: UIViewController)
}

class NewGameRoomViewController: MenuController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startBtn: UIButton!
    
    private var players = [String]()
    
    weak var gameRoomDelegate: GameRoomDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.layer.cornerRadius = Constants.Table.CornerRadius
        tableView.alpha = Constants.Table.Alpha
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startBtnPressed(sender: AnyObject) {
        if let delegate = gameRoomDelegate {
            delegate.startNewGame(self, allPlayers: players)
        }
    }
    
    @IBAction func quitBtnPressed(sender: AnyObject) {
        if let delegate = gameRoomDelegate {
            delegate.quitGameRoom(self)
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
            // connected with host, enter game and set game scene
            if find(self.players, playerName) == nil {
                self.players.append(playerName)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.players.count, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
                
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
   
    func browser(foundPlayer playerName: String, withDiscoveryInfo info: [NSObject : AnyObject]?) {
    }
    
    func browser(lostPlayer playerName: String) {
    }
}

extension NewGameRoomViewController: SessionDataDelegate {
    func session(player playername: String, didChangeState state: MCSessionState) {
        switch state {
        case .Connected:
            if find(players, playername) == nil {
                players.append(playername)
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: players.count, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            break
        case .Connecting:
            // try connecting to the host, show an indicator with cancel button
            break
        case .NotConnected:
            // there is a problem connecting with the host, show an alert message
            if let index = find(players, playername) {
                players.removeAtIndex(index)
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index + 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                if players.isEmpty {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            break
        default:
            break
        }
    }
    
    // Received data from remote player
    func session(didReceiveData data: NSData, fromPlayer playerName: String) {
        let unarchivedData: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        if let gameInitData = unarchivedData as? GameNetworkInitData {
            if let delegate = gameRoomDelegate {
                delegate.joinNewGame(self, pacmanId: gameInitData.pacmanId, mapContent: gameInitData.mapContent, miniMapImage: gameInitData.miniMapImage)
            }
        }
    }
}