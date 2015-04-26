//
//  GameNetworkData.swift
//  Pacman Reloaded
//
//  Created by panlong on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

// This file defines various formats of game network data
// It has to comform to NSCoding such that it can be encoded into NSData and sent using MultipeerConnectivity framework
class GameNetworkInitData: NSObject, NSCoding {
    // during the game init, this data will be sent by the host to all clients.
    // including the allocated pacmanId for client, map data including minimap background image
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

class GameNetworkInitACKData: NSObject, NSCoding {
    // This is simply a ACK package to notify the host that the client has received game init data
    // and the game can be started
    override init(){super.init()}
    required init(coder aDecoder: NSCoder) {super.init()}
    func encodeWithCoder(aCoder: NSCoder) {}
}

class GameNetworkStartData: NSObject, NSCoding {
    // Sent by the host at start of the game to notify all the clients
    override init(){super.init()}
    required init(coder aDecoder: NSCoder) {super.init()}
    func encodeWithCoder(aCoder: NSCoder) {}
}

class GameNetworkMovementData: NSObject, NSCoding {
    // This package includes the movement data for a movable objects,
    // including the objectId, direction and position
    
    // We will frequently synchronize the positons of movable objects among all
    // devices to achieve seamless gaming experience
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
    // update about the score of a certain pacman identified by its id
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