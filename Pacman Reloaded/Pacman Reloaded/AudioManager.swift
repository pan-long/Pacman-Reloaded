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

private var AudioPlayer: AVAudioPlayer?
class AudioManager {
    struct config {
        static let PacdotSoundEffect = "coin.wav"
        static let MenuSoundEffect = "menu"

    }

    private init() {
        // private initializer since it is a utility class
    }

    // generates a sound effect for use in SKAction queue
    class func pacdotSoundEffectAction() -> SKAction {
        return SKAction.playSoundFileNamed(config.PacdotSoundEffect, waitForCompletion: false)
    }

    // play the menu sound directly
    class func playMenuSound() {
        var sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(config.MenuSoundEffect, ofType: "wav")!)
        println(sound)

        // Removed deprecated use of AVAudioSessionDelegate protocol
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)

        var error:NSError?
        if AudioPlayer == nil {
            AudioPlayer = AVAudioPlayer(contentsOfURL: sound, error: &error)
        }
        AudioPlayer?.prepareToPlay()
        AudioPlayer?.volume = 1.0
        AudioPlayer?.play()
    }
}