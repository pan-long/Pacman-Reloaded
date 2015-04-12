//
//  Constants.swift
//  Pacman Reloaded
//
//  Created by Su Xuan on 28/3/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import SpriteKit
import Foundation

struct Constants {
    static let gameResumeCountDownNumber = 3
    
    static let IPadWidth = CGFloat(1024)
    static let IPadHeight = CGFloat(768)
    static let FrameInterval = 2

    struct Score {
        static let PacDot = 1
        static let Ghost = 10
    }

    struct Ghost {
        static let speed = CGFloat(4)
        static let defaultImageSuffix = "-right"
        static let frightenedImage = "ghost-frightened"
        static let eatedImage = "ghost-eyes"
        static let imageSeparator = "-"
        static let FrightenModeDuration: NSTimeInterval = 10
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
    
    struct GameScene {
        static let GridWidth = CGFloat(40)
        static let GridHeight = GridWidth
        static let NumberOfRows = 50
        static let NumberOfColumns = 50
        
        static let PacmanMaleTag = 10
        static let PacmanFemaleTag = 20
        static let InkyTag = 30
        static let BlinkyTag = 40
        static let PinkyTag = 50
        static let ClydeTag = 60
        static let WallTag = 70
        static let PacdotTag = 80
        static let SuperPacdotTag = 90
        static let EraserTag = 1000
        
        static let MaxNumberOfPacman = 8
        static let MaxNumberOfGhosts = 8
    }
}
