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

class GameNetworkData: NSCoding {
    let dataType: GameNetworkDataType
    
    init(type: GameNetworkDataType) {
        dataType = type
    }
    
    required init(coder aDecoder: NSCoder) {
        dataType = GameNetworkDataType(rawValue: aDecoder.decodeIntegerForKey("dataType"))!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(dataType.rawValue, forKey: "dataType")
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
        let positionX = aDecoder.decodeFloatForKey("positionX")
        let positionY = aDecoder.decodeFloatForKey("positionY")
        position = CGPointMake(CGFloat(positionX), CGFloat(positionY))
        direction = Direction(rawValue: aDecoder.decodeObjectForKey("direction") as String)!
        
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(Float(position.x), forKey: "positionX")
        aCoder.encodeObject(Float(position.y), forKey: "positionY")
        aCoder.encodeObject(direction.rawValue, forKey: "direction")
        
        super.encodeWithCoder(aCoder)
    }
}

class GameNetworkPacmanMovementData: GameNetworkMovementData {
    let playerName: String
    
    init(playerName: String, pacmanPosition: CGPoint, pacmanDirection: Direction) {
        self.playerName = playerName
        
        super.init(type: GameNetworkDataType.TYPE_PACMAN_MOVEMENT, position: pacmanPosition, direction: pacmanDirection)
    }
    
    required init(coder aDecoder: NSCoder) {
        playerName = aDecoder.decodeObjectForKey("playerName") as String
        
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(playerName, forKey: "playerName")
        
        super.encodeWithCoder(aCoder)
    }
}

class GameNetworkGhostMovementData: GameNetworkMovementData {
    let ghostName: String
    
    init(ghostName: String, ghostPosition: CGPoint, ghostDirection: Direction) {
        self.ghostName = ghostName
        
        super.init(type: GameNetworkDataType.TYPE_PACMAN_MOVEMENT, position: ghostPosition, direction: ghostDirection)
    }
    
    required init(coder aDecoder: NSCoder) {
        ghostName = aDecoder.decodeObjectForKey("ghostName") as String
        
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(ghostName, forKey: "ghostName")
        
        super.encodeWithCoder(aCoder)
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
        self.pacmanName = aDecoder.decodeObjectForKey("pacmanName") as String
        self.pacmanScore = aDecoder.decodeIntegerForKey("pacmanScore")
        
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(pacmanName, forKey: "pacmanName")
        aCoder.encodeInteger(pacmanScore, forKey: "pacmanScore")
        
        super.encodeWithCoder(aCoder)
    }
}