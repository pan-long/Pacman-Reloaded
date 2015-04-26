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
    private var otherPacmansNetworkControls = [NetworkMovementControl]()

    var networkDelegate: GameSceneNetworkDelegate?
    
    func setupPacman(fromMapContent content: [Dictionary<String, String>], pacmanId: Int, isHost: Bool) {
        self.pacmanId = pacmanId
        self.isHost = isHost
        
        super.setup(fromMapContent: content)
    }
    
    override func initGameObjects() {
        super.initGameObjects()
        pacman = PacMan(id: pacmanId)
    }
    
    override func setupObjectsMovementControl() {
        if isHost { // do the same thing as single player
            super.setupObjectsMovementControl()
           
        } else { // the movement of ghosts should only be controlled by the host
            ghostMovements.removeAll(keepCapacity: false)
            setGhostNetworkMovementControl(blinkys)
            setGhostNetworkMovementControl(pinkys)
            setGhostNetworkMovementControl(inkys)
            setGhostNetworkMovementControl(clydes)
        }
        
        // extra: add other pacmans network movement control
        for pacman in otherPacmans {
            let pacmanMovement = NetworkMovementControl(movableObject: pacman)
            if let networkDelegate = networkDelegate {
                networkDelegate.setObjectMovementControl(pacman.objectId, movementControl: pacmanMovement)
            }
            
            otherPacmansNetworkControls.append(pacmanMovement)
        }
    }
    
    private func setGhostNetworkMovementControl(ghosts: [Ghost]) {
        for ghost in ghosts {
            let ghostMovement = NetworkMovementControl(movableObject: ghost)
            ghostMovements.append(ghostMovement)
            if let networkDelegate = networkDelegate {
                networkDelegate.setObjectMovementControl(ghost.objectId, movementControl: ghostMovement)
            }
        }
    }
    
    override func setupGameObjects() {
        // setup network delegate for movable objects that are controlled locally
        // local pacman has network delegate
        pacman.networkDelegate = self
//        pacman.scoreNetworkDelegate = self
        
        super.setupGameObjects()
        
        // if I am the host, then all ghost has network delegate also
        if isHost {
            for ghost in ghosts {
                ghost.networkDelegate = self
            }
        }
    }
    
    override func earnExtraPoints(pacman: PacMan) {
        if pacman.objectId == self.pacman.objectId {
            super.earnExtraPoints(pacman)
        }
    }

    override func spotLightMode(pacman: PacMan) {
        if pacman.objectId == self.pacman.objectId {
            super.spotLightMode(pacman)
        }
    }

    override func update(currentTime: CFTimeInterval) {
        for networkControl in otherPacmansNetworkControls {
            networkControl.update()
        }
        
        for pacman in otherPacmans {
            pacman.update()
        }
        
        super.update(currentTime)
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

    override func handlePacmanCaught(pacman: PacMan) {
        if !pacman.invincible {
            if pacman.objectId == self.pacmanId {
                pacman.score += Constants.PacMan.MultiplayerDeathPenalty
                sceneDelegate.updateScore(pacman.score, dotsLeft: totalPacDots)
            }
            makeInvincible(pacman)
        }
    }

    private func makeInvincible(pacman: PacMan) {
        pacman.invincible = true
        let wait = SKAction.waitForDuration(Constants.PacMan.InvincibleDuration)
        let resetInvincible = SKAction.runBlock {
            pacman.invincible = false
        }
        let invincible = SKAction.sequence([wait, resetInvincible])

        let blinkOnce = SKAction.sequence([
            SKAction.fadeOutWithDuration(Constants.PacMan.InvincibleBlinkDuration),
            SKAction.fadeInWithDuration(Constants.PacMan.InvincibleBlinkDuration)
            ])
        let blink = SKAction.repeatAction(blinkOnce, count: Constants.PacMan.InvincibleBlinkCount)

        pacman.runAction(SKAction.group([invincible, blink]), withKey: "respawn")
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

    override func getPacmans() -> [MovableObject] {
        var pacmans = [MovableObject]()
        pacmans.append(pacman)
        for pac in self.otherPacmans {
            pacmans.append(pac)
        }
        return pacmans
    }

}