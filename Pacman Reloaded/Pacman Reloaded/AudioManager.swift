//
//  AudioManager.swift
//  Pacman Reloaded
//
//  Created by BenMQ on 29/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class AudioManager {
    struct config {
        static let pacdotSoundEffect = "pacman_chomp.wav"
    }

    class func pacdotSoundEffectAction() -> SKAction {
        return SKAction.playSoundFileNamed(config.pacdotSoundEffect, waitForCompletion: false)
    }
}