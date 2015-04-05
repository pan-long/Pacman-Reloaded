//
//  GameCenter.swift
//  Pacman Reloaded
//
//  Created by panlong on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class GameCenter {
    let selfName: String
    let hostName: String
    let otherPlayersName: [String]
    
    let connectivity: MultiplayerConnectivity
    var scene: MultiplayerGameScene?
    
    init(selfName: String, hostName: String, otherPlayersName: [String], connectivity: MultiplayerConnectivity) {
        self.selfName = selfName
        self.hostName = hostName
        self.otherPlayersName = otherPlayersName
        self.connectivity = connectivity
    }
    
    func updateGameStatus(gameStatus data: GameNetworkData) {
        var error: NSError?
        if selfName == hostName { // if I am the host, I simply notify all the other players
            connectivity.sendData(toPlayer: otherPlayersName, data: data, error: &error)
        } else { // we are not the host, we need to send this package to the host and the host will then distributed it to other players
            connectivity.sendData(toPlayer: [hostName], data: data, error: &error)
        }
        
        if error != nil {
            println("error sending data!")
        }
    }
}

extension GameCenter: SessionDataDelegate {
    // Received data from remote player
    func session(didReceiveData data: NSData, fromPlayer playerName: String) {
        var error: NSError?
        if selfName == hostName {// if this is the host, you need to forward it to other players
            connectivity.sendData(toPlayer: otherPlayersName.filter({$0 != playerName}), data: data, error: &error)
        }
        
        processPackage(data as GameNetworkData)
    }
    
    // The connection status has been changed on the other end
    func session(player playerName: String, didChangeState state: MCSessionState) {
        println("Peers status change not implemented in GameCenter")
    }
    
    private func processPackage(data: GameNetworkData) {
        if let scene = scene {
        }
    }
}

extension GameCenter: GameSceneNetworkDelegate {
    func updateStatus(pacman: PacMan, ghost: Ghost) {
        
    }
}