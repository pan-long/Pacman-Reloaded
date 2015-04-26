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
    static let IPadWidth = CGFloat(1024)
    static let IPadHeight = CGFloat(768)
    static let FrameInterval = 3
    
    struct Item {
        static let SizeScale = CGFloat(1)
    }
    
    struct MovableObject {
        static let SizeScale = CGFloat(0.5)
    }

    struct Score {
        static let PacDot = 10
        static let Ghost = 100
        static let ExtraPointDot = 200
    }

    struct Ghost {
        static let Speed = CGFloat(4)
        static let FrightenSpeed = CGFloat(2)
        static let EatenSpeed = CGFloat(6)
        static let DefaultImageSuffix = "-right"
        static let FrightenedImage = "ghost-frightened"
        static let EatedImage = "ghost-eyes"
        static let ImageSeparator = "-"
        static let FrightenModeDuration: NSTimeInterval = 8
        static let FrightenModeBlinkDuration: NSTimeInterval = 0.2
        static let FrightenModeBlinkCount = 5
    }
    
    struct PacMan {
        static let Width = CGFloat(30)
        static let Height = CGFloat(30)
        static let Speed = CGFloat(4)

        static let InvincibleDuration: NSTimeInterval = 4
        static let InvincibleBlinkDuration: NSTimeInterval = 0.2
        static let InvincibleBlinkCount = 5

        static let MultiplayerDeathPenalty = -100

        static let ImageCount = 2
        static let Images = ["pacman-female", "pacman-male"]
        static let Filenames = [
            ["pacman-female00", "pacman-female01"],
            ["pacman-male00", "pacman-male01"]]
    }

    struct PacDot {
        static let NormalPacDotImage = "pacdot"
        static let SuperPacDotImage = "super-pacdot"
        static let ZPosition = CGFloat(-90)
    }

    struct Locale {
        static let GameOver = "Game Over"
        static let GameWin = "You win!"
    }

    static let InvitePlayerTimeout: NSTimeInterval = 20
    struct Identifiers {
        // Single player segue identifier
        static let SinglePlayerGameSegueIdentifier = "SinglePlayerGameSeuge"
        static let MultiplayerGameSegueIdentifier = "MultiplayerGameSegue"
        
        // Game network service identifier
        static let NewGameService = "pacman-game"
        
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

        static let BoundaryImage = "boundary"

        static let PacdotRatio: Double = 4
        static let Width = 720
        static let Height = 720
        static let TotalWidth = 1600
        static let TotalHeight = 1600
        static let MiniMapWidth = 256
        static let MiniMapHeight = 256
        static let MiniMapAlpha: CGFloat = 0.5
        
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
        static let RecCenterMinX = MiniGridWidth * CGFloat(Double(NumberOfColumnsPerScreen / 2) - 0.5)
        static let RecCenterMinY = MiniGridHeight * CGFloat(Double(NumberOfRowsPerScreen / 2) - 0.5)
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
        
        static let GameSceneViewAlphaStart: CGFloat = 0
        static let GameSceneViewAlphaEnd: CGFloat = 1
    }
    
    struct AIMovementControl {
        static let GameSceneMinX: CGFloat = 0
        static let GameSceneMinY: CGFloat = 0
        static let GameSceneMaxX = Constants.GameScene.GridWidth  * CGFloat(Constants.GameScene.NumberOfColumns)
        static let GameSceneMaxY = Constants.GameScene.GridHeight * CGFloat(Constants.GameScene.NumberOfRows)
        
        static let IndefiniteChase = 2100
        static let ChaseModeDuration = 400
        static let ScatterModeDuration = 100
    }

    struct MainMenu {
        static let OffscreenYPosition = CGFloat(-60)
        static let ItemDamping = CGFloat(0.3)

        static let ParallaxLeftRightMin = CGFloat(-50)
        static let ParallaxLeftRightMax = -1 * ParallaxLeftRightMin
        static let ParallaxLeftRightKeyPath = "center.x"

        static let ParallaxUpDownMin = CGFloat(-50)
        static let ParallaxUpDownMax = -1 * ParallaxUpDownMin
        static let ParallaxUpDownKeyPath = "center.y"

        static let SinglePlayerCenter = CGPoint(x: 512.5, y: 421.0)
        static let MultiPlayerCenter = CGPoint(x: 512.5, y: 496.0)
        static let LevelDesignerCenter = CGPoint(x: 512.5, y: 571.0)

        static let SinglePlayerIconCenter = CGPoint(x: 287.0, y: 421.0)
        static let MultiPlayerIconCenter = CGPoint(x: 318.0, y: 492.0)
        static let LevelDesignerIconCenter = CGPoint(x: 280.0, y: 571.0)
    }
}
