//
//  NewGameRoomViewController.swift
//  Pacman Reloaded
//
//  Created by panlong on 21/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class NewGameRoomViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startBtn: UIButton!
    
    private var players = [String]()
    
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
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: players.count, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case .Connecting:
            // try connecting to the host, show an indicator with cancel button
            break
        case .NotConnected:
            // there is a problem connecting with the host, show an alert message
            let index = find(players, playername)!
            players.removeAtIndex(index)
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index + 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
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