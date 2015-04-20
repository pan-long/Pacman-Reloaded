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
    
    private var objectMovementControl = [Int: NetworkMovementControl]()
    
    private var mapContent: [Dictionary<String, String>]
    
    let connectivity: MultiplayerConnectivity
    
    init(selfName: String, hostName: String, otherPlayersName: [String],pacmanId: Int, mapContent: [Dictionary<String, String>], connectivity: MultiplayerConnectivity) {
        self.selfName = selfName
        self.hostName = hostName
        self.otherPlayersName = otherPlayersName
        
        self.pacmanId = pacmanId
        self.mapContent = mapContent
        
        self.connectivity = connectivity
    }
}

extension GameCenter: SessionDataDelegate {
    // Received data from remote player
    func session(didReceiveData data: NSData, fromPlayer playerName: String) {
        var error: NSError?
        processPackage(data)
    }
    
    // The connection status has been changed on the other end
    func session(player playerName: String, didChangeState state: MCSessionState) {
        println("Peers status change not implemented in GameCenter")
    }
    
    private func processPackage(data: NSData) {
        println("processing network data")
        let unarchivedData: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        if let objectMovementData = unarchivedData as? GameNetworkMovementData {
            let objectId = objectMovementData.objectId
            let networkMovementControl = objectMovementControl[objectId]
            
            if selfName == hostName { // if the player is the host, it will receive the movementdata of other pacmans
                let object = networkMovementControl!.movableObject
                let correctedNetworkMovementData = GameNetworkMovementData(objectId: objectId, position: object.position, direction: objectMovementData.direction)
                let archivedData = NSKeyedArchiver.archivedDataWithRootObject(correctedNetworkMovementData)
                connectivity.sendData(toPlayer: otherPlayersName, data: archivedData, error: nil)
            } else { // correct the location from host first
                networkMovementControl?.correctPosition(objectMovementData.position)
            }
            
            // don't change the direction twice
            if self.pacmanId != objectId {
                networkMovementControl?.changeDirection(objectMovementData.direction)
            }
        } else if let pacmanScoreData = unarchivedData as? GameNetworkPacmanScoreData {
            let pacmanId = pacmanScoreData.pacmanId
            let networkMovementControl = objectMovementControl[pacmanId]
            var pacman = networkMovementControl?.movableObject as PacMan
            if pacman.score != pacmanScoreData.pacmanScore {
                if selfName == hostName {
                    let correctedPacmanScoreData = GameNetworkPacmanScoreData(pacmanId: pacmanScoreData.pacmanId, pacmanScore: pacman.score)
                    let archivedData = NSKeyedArchiver.archivedDataWithRootObject(correctedPacmanScoreData)
                    connectivity.sendData(toPlayer: otherPlayersName, data: archivedData, error: nil)
                } else {
                    pacman.score = pacmanScoreData.pacmanScore
                }
            }
        }
    }
}

extension GameCenter: GameSceneNetworkDelegate {
    func updateObjectMovementData(objectId: Int, newDirection: Direction, position: CGPoint) {
        let objectMovementData = GameNetworkMovementData(objectId: objectId, position: position, direction: newDirection)
        let archivedData = NSKeyedArchiver.archivedDataWithRootObject(objectMovementData)
        
        if selfName == hostName {
            connectivity.sendData(toPlayer: otherPlayersName, data: archivedData, error: nil)
        } else {
            connectivity.sendData(toPlayer: [hostName], data: archivedData, error: nil)
        }
    }
    
    func updatePacmanScore(pacmanId: Int, newScore: Int) {
        let pacmanScoreData = GameNetworkPacmanScoreData(pacmanId: pacmanId, pacmanScore: newScore)
        let archivedData = NSKeyedArchiver.archivedDataWithRootObject(pacmanScoreData)
        
        if selfName == hostName {
            connectivity.sendData(toPlayer: otherPlayersName, data: archivedData, error: nil)
        } else {
            connectivity.sendData(toPlayer: [hostName], data: archivedData, error: nil)
        }
    }
    
    func setObjectMovementControl(objectId: Int, movementControl: NetworkMovementControl) {
        objectMovementControl[objectId] = movementControl
    }
}