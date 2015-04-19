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
    func updatePacmanMovementData(pacman: PacMan)
    func updateGhostMovementData(id: Int, ghost: Ghost)
    func updatePacmanScore(pacman: PacMan)
    func setPacmanMovementControl(id: Int, movementControl: NetworkMovementControl)
    func setGhostMovementControl(id: Int, movementControl: NetworkMovementControl)
}

class MultiplayerGameScene: GameScene {
    private var isHost = false
    
    private var pacmanId = 0
    private var otherPacmans = [PacMan]()
    
    var networkDelegate: GameSceneNetworkDelegate?
    
    func setupPacman(pacmanId: Int, isHost: Bool) {
        self.pacmanId = pacmanId
        self.isHost = isHost
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        registerObserverForPacmanDirection()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &movableObjectContex {
            if let networkDelegate = networkDelegate {
                networkDelegate.updatePacmanMovementData(pacman)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    private func registerObserverForPacmanDirection() {
        pacman.addObserver(self, forKeyPath: "currentDirRaw", options: .New, context: &movableObjectContex)
    }
    
    private func removeObserverForPacmanDirection() {
        pacman.removeObserver(self, forKeyPath: "currentDirRaw", context: &movableObjectContex)
    }
    
    deinit {
        removeObserverForPacmanDirection()
    }
    
    override func setupObjectsMovementControl() {
        if isHost { // do the same thing as single player
            super.setupObjectsMovementControl()
        } else { // the movement of ghosts should only be controlled by the host
            for blinky in blinkys {
                var blinkyMovement = NetworkMovementControl(movableObject: blinky)
                ghostMovements.append(blinkyMovement)
                networkDelegate!.setGhostMovementControl(blinky.objectId!, movementControl: blinkyMovement)
            }
            
            for pinky in pinkys {
                var pinkyMovement = NetworkMovementControl(movableObject: pinky)
                ghostMovements.append(pinkyMovement)
                networkDelegate!.setGhostMovementControl(pinky.objectId!, movementControl: pinkyMovement)
            }
            
            for inky in inkys {
                var inkyMovement = NetworkMovementControl(movableObject: inky)
                ghostMovements.append(inkyMovement)
                networkDelegate!.setGhostMovementControl(inky.objectId!, movementControl: inkyMovement)
            }
            
            for clyde in clydes {
                var clydeMovement = NetworkMovementControl(movableObject: clyde)
                ghostMovements.append(clydeMovement)
                networkDelegate!.setGhostMovementControl(clyde.objectId!, movementControl: clydeMovement)
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
        removeObserverForPacmanDirection()
        otherPacmans.removeAll(keepCapacity: false)
        super.restart()
        registerObserverForPacmanDirection()
    }
    
    override func addPacmanFromTMXFile(id: Int, position: CGPoint) {
        var newPacman: PacMan!
        
        if id == pacmanId {
            newPacman = pacman
        } else {
            let pacman = PacMan(id: id)
            otherPacmans.append(pacman)
            let networkMovementControl = NetworkMovementControl(movableObject: pacman)
            if let networkDelegate = networkDelegate {
                networkDelegate.setPacmanMovementControl(id, movementControl: networkMovementControl)
            }
            newPacman = pacman
        }
        
        newPacman.position = position
        addChild(newPacman)
    }
}