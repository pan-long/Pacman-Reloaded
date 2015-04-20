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
    
    // own pacman id
    private var pacmanId: Int
    private var ownPacman: PacMan
    
    private var pacmanMovementControl = [Int: NetworkMovementControl]()
    private var ghostMovementControl = [Int: NetworkMovementControl]()
    
    let connectivity: MultiplayerConnectivity
    
    init(selfName: String, hostName: String, pacman: PacMan, otherPlayersName: [String], connectivity: MultiplayerConnectivity) {
        self.selfName = selfName
        self.hostName = hostName
        self.ownPacman = pacman
        self.pacmanId = pacman.objectId
        self.otherPlayersName = otherPlayersName
        self.connectivity = connectivity
    }
    
    func updateGameStatus(gameStatus data: GameNetworkData) {
        var error: NSError?
        if selfName == hostName { // if I am the host, simply notify all the other players
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
        
        processPackage(data as GameNetworkData)
    }
    
    // The connection status has been changed on the other end
    func session(player playerName: String, didChangeState state: MCSessionState) {
        println("Peers status change not implemented in GameCenter")
    }
    
    private func processPackage(data: GameNetworkData) {
        println("processing network data")
        switch data.dataType {
        case GameNetworkDataType.TYPE_PACMAN_MOVEMENT:
            let pacmanMovementData = data as GameNetworkPacmanMovementData
            let pacmanId = pacmanMovementData.pacmanId
            let networkMovementControl = pacmanMovementControl[pacmanId]
            
            if selfName == hostName { // if the player is the host, correct the position and update other players
                let pacman = networkMovementControl?.movableObject as PacMan
                let correctedNetworkMovementData = GameNetworkPacmanMovementData(pacmanId: pacmanId, pacmanPosition: pacman.position, pacmanDirection: pacmanMovementData.direction)
                connectivity.sendData(toPlayer: otherPlayersName, data: correctedNetworkMovementData, error: nil)
            } else if self.pacmanId != pacmanId { // if the player is not the host, simply corrected the position
                networkMovementControl?.correctPosition(pacmanMovementData.position)
            } else { // correct own position
                ownPacman.position = pacmanMovementData.position
            }
            
            // don't change the direction twice
            if self.pacmanId != pacmanId {
                networkMovementControl?.changeDirection(pacmanMovementData.direction)
            }
            
            break
        case GameNetworkDataType.TYPE_GHOST_MOVEMENT:
            let ghostMovementData = data as GameNetworkGhostMovementData
            let ghostId = ghostMovementData.ghostId
            let networkMovementControl = ghostMovementControl[ghostId]
            networkMovementControl?.correctPosition(ghostMovementData.position)
            networkMovementControl?.changeDirection(ghostMovementData.direction)
            break
        case GameNetworkDataType.TYPE_PACMAN_SCORE:
            let pacmanScoreData = data as GameNetworkPacmanScoreData
            let pacmanId = pacmanScoreData.pacmanId
            let networkMovementControl = pacmanMovementControl[pacmanId]
            var pacman = networkMovementControl?.movableObject as PacMan
            pacman.score = pacmanScoreData.pacmanScore
            break
        default:
            break
        }
    }
}

extension GameCenter: GameSceneNetworkDelegate {
    func updatePacmanMovementData(pacman: PacMan) {
        let pacmanMovementData = GameNetworkPacmanMovementData(pacmanId: pacman.objectId, pacmanPosition: pacman.position, pacmanDirection: pacman.currentDir)
        
        // TO-Do: handle error
        connectivity.sendData(toPlayer: otherPlayersName, data: pacmanMovementData, error: nil)
    }
    
    func updateGhostMovementData(id: Int, ghost: Ghost) {
        let ghostMovementData = GameNetworkGhostMovementData(ghostId: id, ghostPosition: ghost.position, ghostDirection: ghost.currentDir)
        connectivity.sendData(toPlayer: otherPlayersName, data: ghostMovementData, error: nil)
    }
    
    func updatePacmanScore(pacman: PacMan) {
        let pacmanScoreData = GameNetworkPacmanScoreData(pacmanId: pacman.objectId, pacmanScore: pacman.score)
        connectivity.sendData(toPlayer: otherPlayersName, data: pacmanScoreData, error: nil)
    }
    
    func setPacmanMovementControl(id: Int, movementControl: NetworkMovementControl) {
        pacmanMovementControl[id] = movementControl
    }
    
    func setGhostMovementControl(id: Int, movementControl: NetworkMovementControl) {
        ghostMovementControl[id] = movementControl
    }
}