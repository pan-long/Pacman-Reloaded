//
//  MultiplayerViewController.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

class MultiplayerViewController: UIViewController {
    @IBOutlet var createNewRoom: UIButton!
    
    var connectivity = MultiplayerConnectivity(name: "multiplayerMode")
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.blackColor()
        connectivity.startServiceBrowsing("searchingForRooms")
        println("asd")
    }
    
    
    @IBAction func createNewRoomClicked(sender: AnyObject) {
        var info = Dictionary<String, String>()
        info["newRoom"] = "asd"
        connectivity.startServiceAdvertising("newRoom", discoveryInfo: info)
        
    }
}

extension MultiplayerViewController: MatchPeersDelegate {
    func didReceiveInvitationFromPlayer(playerName: String, invitationHandler: ((Bool) -> Void)) {
        
    }
    
    func browser(foundPlayer playerName: String) {
        
    }
    
    func browser(lostPlayer playerName: String) {
        
    }
}