//
//  MultiplayerGameScene.swift
//  Pacman Reloaded
//
//  Created by panlong on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit
import AVFoundation

protocol GameSceneNetworkDelegate {
    func updateObjectMovementData(objectId: Int, newDirection: Direction, position: CGPoint)
    func updatePacmanScore(pacmanId: Int, newScore: Int)
    func setObjectMovementControl(objectId: Int, movementControl: NetworkMovementControl)
}

class MultiplayerGameScene: GameScene {
    private var isHost = false
    
    private var pacmanId = 0
    private var otherPacmans = [PacMan]()
    
    var networkDelegate: GameSceneNetworkDelegate?
    var multiplayerDelegate: MultiplayerGameSceneDelegate?
    
    func setupPacman(fromMapContent content: [Dictionary<String, String>], pacmanId: Int, isHost: Bool) {
        super.setup(fromMapContent: content)
        
        self.pacmanId = pacmanId
        self.isHost = isHost
    }
    
    override func setupObjectsMovementControl() {
        if isHost { // do the same thing as single player
            super.setupObjectsMovementControl()
        } else { // the movement of ghosts should only be controlled by the host
            setGhostNetworkMovementControl(blinkys)
            setGhostNetworkMovementControl(pinkys)
            setGhostNetworkMovementControl(inkys)
            setGhostNetworkMovementControl(clydes)
        }
    }
    
    private func setGhostNetworkMovementControl(ghosts: [Ghost]) {
        for ghost in ghosts {
            var ghostMovement = NetworkMovementControl(movableObject: ghost)
            ghostMovements.append(ghostMovement)
            if let networkDelegate = networkDelegate {
                networkDelegate.setObjectMovementControl(ghost.objectId, movementControl: ghostMovement)
            }
        }
    }
    
    override func setupGameObjects() {
        super.setupObjectsMovementControl()
        
        // setup network delegate for movable objects that are controlled locally
        // local pacman has network delegate
        pacman.networkDelegate = self
        pacman.scoreNetworkDelegate = self
        
        // if I am the host, then all ghost has network delegate also
        if isHost {
            for ghost in ghosts {
                ghost.networkDelegate = self
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        for pacman in otherPacmans {
            pacman.update()
        }
        
        super.update(currentTime)
    }
    
    override func restart() {
        fatalError("restart is not supperted in multiplayer mode!")
    }
    
    override func addPacmanFromMapData(id: Int, position: CGPoint) {
        var newPacman: PacMan!
    
        if id == pacmanId { // this is your own ghost
            newPacman = pacman
        } else {
            let pacman = PacMan(id: id)
            otherPacmans.append(pacman)
            let networkMovementControl = NetworkMovementControl(movableObject: pacman)
            if let networkDelegate = networkDelegate {
                networkDelegate.setObjectMovementControl(pacman.objectId, movementControl: networkMovementControl)
            }
            newPacman = pacman
        }
        
        newPacman.position = position
        addChild(newPacman)
    }
}

extension MultiplayerGameScene: MovementNetworkDelegate {
    func objectDirectionChanged(objectId: Int, newDirection: Direction, position: CGPoint) {
        if let networkDelegate = networkDelegate {
            networkDelegate.updateObjectMovementData(objectId, newDirection: newDirection, position: position)
        }
    }
}

extension MultiplayerGameScene: PacmanScoreNetworkDelegate {
    func pacmanScoreUpdated(pacmanId: Int, newScore: Int) {
        if let networkDelegate = networkDelegate {
            networkDelegate.updatePacmanScore(pacmanId, newScore: newScore)
        }
    }
}

extension MultiplayerGameScene {
    override func getMovableObjects() -> [MovableObject] {
        var res = super.getMovableObjects()
        res = res + otherPacmans
        return res
    }
}