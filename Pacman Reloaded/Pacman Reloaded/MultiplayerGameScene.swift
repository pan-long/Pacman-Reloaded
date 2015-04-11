//
//  MultiplayerGameScene.swift
//  Pacman Reloaded
//
//  Created by panlong on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

protocol GameSceneNetworkDelegate {
    func updateStatus(pacman: PacMan, ghost: Ghost)
}

class MultiplayerGameScene: GameScene {
    private let isHost: Bool
    
    private var otherPacmans = [String: PacMan]()
    private var ghosts = [String: Ghost]()
    
    var networkDelegate: GameSceneNetworkDelegate?
    
    init(isHost: Bool) {
        self.isHost = isHost
        
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
    
    private func removeObserverForPacmanDirection() {
        pacman.removeObserver(self, forKeyPath: "currentDirRaw", context: &movableObjectContex)
    }
    
    deinit {
        removeObserverForPacmanDirection()
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
        if otherPacmans[playerName] == nil { // we only allow pacman to be added once for each player
           otherPacmans[playerName] = pacman
            addChild(pacman)
        }
    }
    
    func updatePacmanPosition(forPlayer player: String, position: CGPoint) {
        if !isHost { // pacman's location is determined by the host
            if let pacman = otherPacmans[player] { // if this pacman exists
                pacman.position = position
            }
        }
    }
    
    func updatePacmanDirection(forPlayer player:String, direction: Direction) {
        if let pacman = otherPacmans[player] {
            pacman.changeDirection(direction)
        }
    }
    
    func updateLocalPacman(position: CGPoint, direction: Direction) {
        if !isHost { // host will not be updated by other client
            removeObserverForPacmanDirection() // remove the observer for updating to avoid cycle in updating
            pacman.position = position
            pacman.changeDirection(direction)
            registerObserverForPacmanDirection()
        }
    }
    
    func updatePacmanScore(forPlayer player: String, score: Int) {
        if !isHost {
            if let pacman = otherPacmans[player] {
                pacman.score = score
            }
        }
    }
    
    func updateGhost(forGhost ghostName: String, position: CGPoint, direction: Direction) {
        if !isHost {
            if let ghost = ghosts[ghostName] {
                ghost.position = position
                ghost.changeDirection(direction)
            }
        }
    }
}