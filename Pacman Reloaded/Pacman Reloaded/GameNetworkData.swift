//
//  GameNetworkData.swift
//  Pacman Reloaded
//
//  Created by panlong on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

enum GameNetworkDataType: Int {
    case TYPE_OBJECT_MOVEMENT = 0,
    TYPE_PACMAN_SCORE = 1,
    TYPE_MAP = 2
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

class GameNetworkMapData: GameNetworkData {
    let pacmanId: Int
    let mapContent: [Dictionary<String, String>]
    
    init(type: GameNetworkDataType, pacmanId: Int, mapContent: [Dictionary<String, String>]) {
        self.pacmanId = pacmanId
        self.mapContent = mapContent
        super.init(type: type)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameNetworkMovementData: GameNetworkData {
    let objectId: Int
    let position: CGPoint
    let direction: Direction
    
    init(objectId: Int, position: CGPoint, direction: Direction) {
        self.objectId = objectId
        self.position = position
        self.direction = direction
        
        super.init(type: GameNetworkDataType.TYPE_OBJECT_MOVEMENT)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameNetworkPacmanScoreData: GameNetworkData {
    let pacmanId: Int
    let pacmanScore: Int
    
    init(pacmanId: Int, pacmanScore: Int) {
        self.pacmanId = pacmanId
        self.pacmanScore = pacmanScore
        
        super.init(type: GameNetworkDataType.TYPE_PACMAN_SCORE)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}