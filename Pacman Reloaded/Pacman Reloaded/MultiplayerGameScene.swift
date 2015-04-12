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
    func updateGhostMovementData(name: String, ghost: Ghost)
    func updatePacmanScore(pacman: PacMan)
    func setPacmanMovementControl(id: Int, movementControl: NetworkMovementControl)
    func setGhostMovementControl(name: String, movementControl: NetworkMovementControl)
}

class MultiplayerGameScene: GameScene {
    private let isHost: Bool
    
    private let pacmanId: Int
    private var otherPacmans = [PacMan]()
    
    var networkDelegate: GameSceneNetworkDelegate?
    
    init(pacmanId: Int, isHost: Bool) {
        self.pacmanId = pacmanId
        self.isHost = isHost
        
        super.init()
        
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
            blinkyMovement = BlinkyAIMovememntControl(movableObject: blinky)
            pinkyMovement = PinkyAIMovementControl(movableObject: pinky)
            inkyMovement = InkyAIMovememntControl(movableObject: inky)
            clydeMovement = ClydeAIMovememntControl(movableObject: clyde)
        } else { // the movement of ghosts should only be controlled by the host
            blinkyMovement = NetworkMovementControl(movableObject: blinky) as NetworkMovementControl
            pinkyMovement = NetworkMovementControl(movableObject: pinky)
            inkyMovement = NetworkMovementControl(movableObject: inky)
            clydeMovement = NetworkMovementControl(movableObject: clyde)
            
            if let networkDelegate = networkDelegate {
                networkDelegate.setGhostMovementControl(GhostName.GHOST_NAME_BLINKY, movementControl: blinkyMovement as NetworkMovementControl)
                networkDelegate.setGhostMovementControl(GhostName.GHOST_NAME_PINKY, movementControl: pinkyMovement as NetworkMovementControl)
                networkDelegate.setGhostMovementControl(GhostName.GHOST_NAME_INKY, movementControl: inkyMovement as NetworkMovementControl)
                networkDelegate.setGhostMovementControl(GhostName.GHOST_NAME_CLYDE, movementControl: clydeMovement as NetworkMovementControl)
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        for pacman in otherPacmans {
            pacman.update()
        }
        
        super.update(currentTime)
    }
    
    override func getVisibleObjects() -> [MovableObject] {
        return super.getVisibleObjects() + otherPacmans
    }
    
    override func restart() {
        super.restart()
        otherPacmans.removeAll(keepCapacity: false)
    }
    
    override func addPacmanFromTMXFile(id: Int, position: CGPoint) {
        let pacman = PacMan(id: id)
        pacman.position = position
        if id == pacmanId {
            self.pacman.position = position
        } else {
            otherPacmans.append(pacman)
            let networkMovementControl = NetworkMovementControl(movableObject: pacman)
            if let networkDelegate = networkDelegate {
                networkDelegate.setPacmanMovementControl(id, movementControl: networkMovementControl)
            }
        }
        
        addChild(pacman)
    }
}