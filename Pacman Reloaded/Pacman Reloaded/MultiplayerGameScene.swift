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
    func updateStatus(pacman: PacMan, ghost: Ghost)
}

class MultiplayerGameScene: GameScene {
    private var otherPacmans = [String: PacMan]()
    
    var networkDelegate: GameSceneNetworkDelegate?
    
    override init() {
        super.init()
        registerObserverForPacmanDirection()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &movableObjectContex {
            if let networkDelegate = networkDelegate {
                networkDelegate.updateStatus(pacman, ghost: blinky)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    private func registerObserverForPacmanDirection() {
        pacman.addObserver(self, forKeyPath: "currentDirRaw", options: .New, context: &movableObjectContex)
    }
    
    private func deregisterObserverForPacmanDirection() {
        pacman.removeObserver(self, forKeyPath: "currentDirRaw", context: &movableObjectContex)
    }
    
    deinit {
        deregisterObserverForPacmanDirection()
    }
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
        for pacman in otherPacmans.values {
            pacman.update()
        }
    }
    
    override func getVisibleObjects() -> [MovableObject] {
        return super.getVisibleObjects() + Array(otherPacmans.values)
    }
    
    override func restart() {
        super.restart()
        otherPacmans.removeAll(keepCapacity: false)
    }
    
    func addPacman(playerName: String, pacman: PacMan) {
        otherPacmans[playerName] = pacman
        addChild(pacman)
    }
    
    func getLocalPacman() -> PacMan {
        let localPacman = pacman
        return localPacman
    }
    
    func updatePacman(forPlayer player: String, newPacman: PacMan) {
        otherPacmans[player] = newPacman
    }
    
    func updateLocalPacman(newPacman: PacMan) {
        deregisterObserverForPacmanDirection()
        pacman.position = newPacman.position
        pacman.changeDirection(newPacman.currentDir)
        registerObserverForPacmanDirection()
    }
}