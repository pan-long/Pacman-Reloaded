//
//  Constants.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 28/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit

struct Constants {
    static let gameResumeCountDownNumber = 3
    
    static let IPadWidth = CGFloat(1024)
    static let IPadHeight = CGFloat(768)
    
    struct Ghost {
        static let speed = CGFloat(5)
    }
    struct PacMan {
        static let Width = CGFloat(30)
        static let Height = CGFloat(30)
        static let speed = CGFloat(5)
    }

    struct PacDot {
        static let normalPacDotImage = "pacdot"
        static let superPacDotImage = "super-pacdot"
    }
    
    static let invitePlayerTimeout: NSTimeInterval = 2000
}
