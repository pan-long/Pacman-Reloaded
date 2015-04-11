//
//  GameNetworkData.swift
//  Pacman Reloaded
//
//  Created by panlong on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

enum GameNetworkDataType: Int {
    case TYPE_PACMAN_MOVEMENT = 0,
    TYPE_GHOST_MOVEMENT = 1,
    TYPE_PACMAN_SCORE = 2
}

class GameNetworkData: NSData {
    let dataType: GameNetworkDataType
    
    init(type: GameNetworkDataType) {
        dataType = type
        
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameNetworkMovementData: GameNetworkData {
    let position: CGPoint
    let direction: Direction
    
    init(type: GameNetworkDataType, position: CGPoint, direction: Direction) {
        self.position = position
        self.direction = direction
        
        super.init(type: type)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameNetworkPacmanMovementData: GameNetworkMovementData {
    let playerName: String
    
    init(playerName: String, pacmanPosition: CGPoint, pacmanDirection: Direction) {
        self.playerName = playerName
        
        super.init(type: GameNetworkDataType.TYPE_PACMAN_MOVEMENT, position: pacmanPosition, direction: pacmanDirection)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameNetworkGhostMovementData: GameNetworkMovementData {
    let ghostName: String
    
    init(ghostName: String, ghostPosition: CGPoint, ghostDirection: Direction) {
        self.ghostName = ghostName
        
        super.init(type: GameNetworkDataType.TYPE_PACMAN_MOVEMENT, position: ghostPosition, direction: ghostDirection)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class GameNetworkPacmanScoreData: GameNetworkData {
    let pacmanName: String
    let pacmanScore: Int
    
    init(pacmanName: String, pacmanScore: Int) {
        self.pacmanName = pacmanName
        self.pacmanScore = pacmanScore
        
        super.init(type: GameNetworkDataType.TYPE_PACMAN_SCORE)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}