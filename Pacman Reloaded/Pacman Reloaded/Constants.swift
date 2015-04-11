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
        static let speed = CGFloat(4)
        static let defaultImageSuffix = "-right"
        static let fleeImageSuffix = "-special"
        static let imageSeparator = "-"
    }
    struct PacMan {
        static let Width = CGFloat(30)
        static let Height = CGFloat(30)
        static let speed = CGFloat(4)
    }

    struct PacDot {
        static let normalPacDotImage = "pacdot"
        static let superPacDotImage = "super-pacdot"
        static let zPosition = CGFloat(-90)
    }

    struct Locale {
        static let gameOver = "Game Over"
        static let gameWin = "You win!"
    }

    static let invitePlayerTimeout: NSTimeInterval = 20
    struct Identifiers {
        static let NewGameTableCell = "newGame"
        static let NewGame = "newGame2"
    }
}
