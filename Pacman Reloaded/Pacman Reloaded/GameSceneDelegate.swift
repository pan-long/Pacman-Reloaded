//
//  GameSceneDelegate.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 29/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit

protocol GameSceneDelegate: class {
    // Update the player's score
    func updateScore(score: Int, dotsLeft: Int)

    func gameDidEnd(scene: GameScene, didWin: Bool, score: Int)
    
    // Synchronise the positions of the movable objects in both the main and mini game scene
    func updateMovableObjectPosition()
    func iniatilizeMovableObjectPosition()
    
    // When the light view is in effect on the main scene, the miniMap also needs special effect
    func startLightView()
    func stopLightView()
}
