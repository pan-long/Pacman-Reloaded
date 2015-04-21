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
    
    struct Item {
        static let sizeScale = CGFloat(1)
    }
    
    struct MovableObject {
        static let sizeScale = CGFloat(0.5)
    }

    struct Score {
        static let PacDot = 10
        static let Ghost = 100
        static let ExtraPointDot = 200
    }

    struct Ghost {
        static let speed = CGFloat(4)
        static let FrightenSpeed = CGFloat(2)
        static let EatenSpeed = CGFloat(6)
        static let defaultImageSuffix = "-right"
        static let frightenedImage = "ghost-frightened"
        static let eatedImage = "ghost-eyes"
        static let imageSeparator = "-"
        static let FrightenModeDuration: NSTimeInterval = 8
        static let FrightenModeBlinkDuration: NSTimeInterval = 0.2
        static let FrightenModeBlinkCount = 5
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
        // Single player segue identifier
        static let SinglePlayerGameSegueIdentifier = "SinglePlayerGameSeuge"
        static let MultiplayerGameSegueIdentifier = "MultiplayerGameSegue"
        
        // Game network service identifier
        static let NewGameService = "newgame123"
        
        // Cell reuse identifier
        static let NewGameTableCell = "newGame"
        static let NewGameRoomPlayerCell = "gameRoomPlayerCell"
        static let GameLevelTableCell = "gameLevelTableCell"
        
        // Segue identifier
        static let ShowPopover = "showPopover"
        static let QuitLevelSelection = "unwindToMenuFromLevelLoading"
    }
    
    struct GameScene {
        // amount needed to shift the location of movable objects along x axis
        static let MovableObjectAdjustment = CGFloat(4)

        static let ImageWithoutBoundaryPrefix = "__boundary__"
        
        static let Width = 720
        static let Height = 720
        static let TotalWidth = 1600
        static let TotalHeight = 1600
        static let MiniMapWidth = 256
        static let MiniMapHeight = 256
        
        static let NumberOfRows = 40
        static let NumberOfColumns = 40
        static let NumberOfRowsPerScreen = 18
        static let NumberOfColumnsPerScreen = 18
        
        static let GridWidth = CGFloat(40)
        static let GridHeight = GridWidth
        static let DesignAreaMinX = GridWidth * CGFloat(NumberOfColumnsPerScreen / 2)
        static let DesignAreaMinY = GridHeight * CGFloat(NumberOfRowsPerScreen / 2)
        static let DesignAreaMaxX = GridWidth * CGFloat(NumberOfColumns) - DesignAreaMinX
        static let DesignAreaMaxY = GridHeight * CGFloat(NumberOfRows) - DesignAreaMinY
        static let DesignAreaWidth = GridWidth * CGFloat(NumberOfColumns)
        static let DesignAreaHeight = GridHeight * CGFloat(NumberOfRows)
        
        static let MiniGridWidth = CGFloat(6.4)
        static let MiniGridHeight = MiniGridWidth
        static let RecCenterMinX = MiniGridWidth * CGFloat(NumberOfColumnsPerScreen / 2)
        static let RecCenterMinY = MiniGridHeight * CGFloat(NumberOfRowsPerScreen / 2)
        static let RecCenterMaxX = MiniGridWidth * CGFloat(NumberOfRows) - RecCenterMinX
        static let RecCenterMaxY = MiniGridHeight * CGFloat(NumberOfColumns) - RecCenterMinY
        
        static let PacmanMaleTag = 10
        static let PacmanFemaleTag = 20
        static let InkyTag = 30
        static let BlinkyTag = 40
        static let PinkyTag = 50
        static let ClydeTag = 60
        static let BoundaryTag = 70
        static let PacdotTag = 80
        static let SuperPacdotTag = 90
        static let EraserTag = 1000
        
        static let MaxNumberOfPacman = 8
        static let MaxNumberOfGhosts = 16
        
        static let SpotLightDuration: NSTimeInterval = 15
        static let ExtraPointDuration: NSTimeInterval = 1.0
    }
    
    struct AIMovementControl {
        static let GAME_SCENE_MIN_X: CGFloat = 0
        static let GAME_SCENE_MIN_Y: CGFloat = 0
        static let GAME_SCENE_MAX_X = Constants.GameScene.GridWidth  * CGFloat(Constants.GameScene.NumberOfColumns)
        static let GAME_SCENE_MAX_Y = Constants.GameScene.GridHeight * CGFloat(Constants.GameScene.NumberOfRows)
        
        static let INDEFINITE_CHASE = 2100
        static let CHASE_MODE_DURATION = 400
        static let SCATTER_MODE_DURATION = 100
    }

    struct MainMenu {
        static let ParallaxLeftRightMin = CGFloat(-50)
        static let ParallaxLeftRightMax = -1 * ParallaxLeftRightMin
        static let ParallaxLeftRightKeyPath = "center.x"

        static let ParallaxUpDownMin = CGFloat(-50)
        static let ParallaxUpDownMax = -1 * ParallaxUpDownMin
        static let ParallaxUpDownKeyPath = "center.y"
    }
}
