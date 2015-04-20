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
    TYPE_INIT = 2
}

class GameNetworkData: NSCoding {
    let dataType: GameNetworkDataType
    
    init(type: GameNetworkDataType) {
        dataType = type
    }

    required init(coder aDecoder: NSCoder) {
        self.dataType = GameNetworkDataType(rawValue: aDecoder.decodeIntegerForKey("dataType"))!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(dataType.rawValue, forKey: "dataType")
    }
}

class GameNetworkInitData: GameNetworkData {
    let hostName: String
    let allPlayersName: [String]
    let pacmanId: Int
    let mapContent: [Dictionary<String, String>]
    
    
    init(hostName: String, allPlayersName: [String], pacmanId: Int, mapContent: [Dictionary<String, String>]) {
        self.hostName = hostName
        self.allPlayersName = allPlayersName
        self.pacmanId = pacmanId
        self.mapContent = mapContent
        super.init(type: GameNetworkDataType.TYPE_INIT)
    }

    required init(coder aDecoder: NSCoder) {
        self.hostName = aDecoder.decodeObjectForKey("hostName") as String
        self.allPlayersName = aDecoder.decodeObjectForKey("allPlayersName") as [String]
        self.pacmanId = aDecoder.decodeIntegerForKey("pacmanId")
        self.mapContent = aDecoder.decodeObjectForKey("mapContent") as [Dictionary<String, String>]
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(hostName, forKey: "hostName")
        aCoder.encodeObject(allPlayersName, forKey: "allPlayersName")
        aCoder.encodeInteger(pacmanId, forKey: "pacmanId")
        aCoder.encodeObject(mapContent, forKey: "mapContent")
        super.encodeWithCoder(aCoder)
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
        self.objectId = aDecoder.decodeIntegerForKey("objectId")
        self.position = (aDecoder.decodeObjectForKey("position") as NSValue).CGPointValue()
        self.direction = Direction(rawValue: aDecoder.decodeObjectForKey("direction") as String)!
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(objectId, forKey: "objectId")
        aCoder.encodeObject(NSValue(CGPoint: position), forKey: "position")
        aCoder.encodeObject(direction.rawValue, forKey: "direction")
        super.encodeWithCoder(aCoder)
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
        self.pacmanId = aDecoder.decodeIntegerForKey("pacmanId")
        self.pacmanScore = aDecoder.decodeIntegerForKey("pacmanScore")
        
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(pacmanId, forKey: "pacmanId")
        aCoder.encodeInteger(pacmanScore, forKey: "pacmanScore")
        super.encodeWithCoder(aCoder)
    }
}