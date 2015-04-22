//
//  GameNetworkData.swift
//  Pacman Reloaded
//
//  Created by panlong on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

class GameNetworkInitData: NSObject, NSCoding {
    let pacmanId: Int
    let mapContent: [Dictionary<String, String>]
    let miniMapImage: UIImage
    
    
    init(pacmanId: Int, mapContent: [Dictionary<String, String>], miniMapImage: UIImage) {
        self.pacmanId = pacmanId
        self.mapContent = mapContent
        self.miniMapImage = miniMapImage
        
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        self.pacmanId = aDecoder.decodeIntegerForKey("pacmanId")
        self.mapContent = aDecoder.decodeObjectForKey("mapContent") as [Dictionary<String, String>]
        self.miniMapImage = aDecoder.decodeObjectForKey("miniMapImage") as UIImage
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(pacmanId, forKey: "pacmanId")
        aCoder.encodeObject(mapContent, forKey: "mapContent")
        aCoder.encodeObject(miniMapImage, forKey: "miniMapImage")
    }
}

class GameNetworkMovementData: NSObject, NSCoding {
    let objectId: Int
    let position: CGPoint
    let direction: Direction
    
    init(objectId: Int, position: CGPoint, direction: Direction) {
        self.objectId = objectId
        self.position = position
        self.direction = direction
        
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        self.objectId = aDecoder.decodeIntegerForKey("objectId")
        self.position = (aDecoder.decodeObjectForKey("position") as NSValue).CGPointValue()
        self.direction = Direction(rawValue: aDecoder.decodeObjectForKey("direction") as String)!
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(objectId, forKey: "objectId")
        aCoder.encodeObject(NSValue(CGPoint: position), forKey: "position")
        aCoder.encodeObject(direction.rawValue, forKey: "direction")
    }
}

class GameNetworkPacmanScoreData: NSObject, NSCoding {
    let pacmanId: Int
    let pacmanScore: Int
    
    init(pacmanId: Int, pacmanScore: Int) {
        self.pacmanId = pacmanId
        self.pacmanScore = pacmanScore
        
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        self.pacmanId = aDecoder.decodeIntegerForKey("pacmanId")
        self.pacmanScore = aDecoder.decodeIntegerForKey("pacmanScore")
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(pacmanId, forKey: "pacmanId")
        aCoder.encodeInteger(pacmanScore, forKey: "pacmanScore")
    }
}