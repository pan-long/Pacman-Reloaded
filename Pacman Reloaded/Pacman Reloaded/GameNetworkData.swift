//
//  GameNetworkData.swift
//  Pacman Reloaded
//
//  Created by panlong on 5/4/15.
//  Copyright (c) 2015 cs3217. All rights reserved.
//

import UIKit

class GameNetworkData: NSData {
    let playerName: String
    let pacmanLocation: CGPoint
    let pacmanDirection: Direction
    let ghostLocation: CGPoint
    let ghostDirection: Direction
    
    init(playerName: String, pacmanLocation: CGPoint, pacmanDirection: Direction, ghostLocation: CGPoint, ghostDirection: Direction) {
        self.playerName = playerName
        self.pacmanLocation = pacmanLocation
        self.pacmanDirection = pacmanDirection
        self.ghostLocation = ghostLocation
        self.ghostDirection = ghostDirection
        
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}